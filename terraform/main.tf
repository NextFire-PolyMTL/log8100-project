provider "kubernetes" {
  config_path = var.kubeconfig_path
}

provider "helm" {
  kubernetes {
    config_path = var.kubeconfig_path
  }
  registry_config_path   = ".helm/config.json"
  repository_cache       = ".helm/repository"
  repository_config_path = ".helm/repositories.yaml"
}

resource "helm_release" "gitlab_runner" {
  name             = "gitlab-runner"
  namespace        = "gitlab"
  create_namespace = true

  repository = "https://charts.gitlab.io"
  chart      = "gitlab-runner"
  version    = "0.58.2"

  timeout = var.helm_timeout

  values = [
    <<-EOF
    gitlabUrl: https://gitlab.com
    runnerToken:  # sensitive
    rbac:
      create: true
    EOF
  ]

  set_sensitive {
    name  = "runnerToken"
    value = var.gitlab_runner_token
  }
}

resource "helm_release" "prometheus_operator_crds" {
  name             = "prometheus-operator-crds"
  namespace        = "monitoring"
  create_namespace = true

  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus-operator-crds"
  version    = "6.0.0"

  timeout = var.helm_timeout
}

resource "helm_release" "kube_prometheus_stack" {
  name             = "kube-prometheus-stack"
  namespace        = "monitoring"
  create_namespace = true

  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "52.1.0"

  depends_on = [helm_release.prometheus_operator_crds]
  timeout    = var.helm_timeout

  values = [
    <<-EOF
    alertmanager:
      config:
        route:
          receiver: discord
          group_interval: 1m
        receivers:
          - name: "null"
          - name: discord
            discord_configs:
              - webhook_url:  # sensitive
      alertmanagerSpec:
        storage:
          volumeClaimTemplate:
            spec:
              accessModes:
                - ReadWriteOnce
              resources:
                requests:
                  storage: 1Gi
      ingress:
        enabled: true
        annotations:
          traefik.ingress.kubernetes.io/router.entrypoints: web,websecure
        hosts:
          - alertmanager.${var.domain}
    grafana:
      deploymentStrategy:
        type: Recreate
      adminPassword:  # sensitive
      persistence:
        enabled: true
        accessModes:
          - ReadWriteOnce
        size: 1Gi
      dashboardProviders:
        dashboardproviders.yaml:
          apiVersion: 1
          providers:
            - name: 'default'
              orgId: 1
              folder: ''
              type: file
              disableDeletion: false
              editable: true
              options:
                path: /var/lib/grafana/dashboards/default
      dashboards:
        default:
          trivy-operator:
            gnetId: 17813
            datasource:
              - name: DS_PROMETHEUS
                value: prometheus
      ingress:
        enabled: true
        annotations:
          traefik.ingress.kubernetes.io/router.entrypoints: web,websecure
        hosts:
          - grafana.${var.domain}
    prometheus:
      prometheusSpec:
        ruleSelectorNilUsesHelmValues: false
        serviceMonitorSelectorNilUsesHelmValues: false
        podMonitorSelectorNilUsesHelmValues: false
        probeSelectorNilUsesHelmValues: false
        retentionSize: 9GiB
        storageSpec:
          volumeClaimTemplate:
            spec:
              accessModes:
                - ReadWriteOnce
              resources:
                requests:
                  storage: 10Gi
      ingress:
        enabled: true
        annotations:
          traefik.ingress.kubernetes.io/router.entrypoints: web,websecure
        hosts:
          - prometheus.${var.domain}
    EOF
  ]

  set_sensitive {
    name  = "alertmanager.config.receivers[1].discord_configs[0].webhook_url"
    value = var.alertmanager_discord_webhook_url
  }

  set_sensitive {
    name  = "grafana.adminPassword"
    value = var.grafana_admin_password
  }
}

resource "helm_release" "trivy_operator" {
  name             = "trivy-operator"
  namespace        = "trivy-system"
  create_namespace = true

  repository = "https://aquasecurity.github.io/helm-charts/"
  chart      = "trivy-operator"
  version    = "0.18.4"

  depends_on = [helm_release.prometheus_operator_crds]
  timeout    = var.helm_timeout

  values = [
    <<-EOF
    operator:
      scanJobsConcurrentLimit: 1
    serviceMonitor:
      enabled: true
    EOF
  ]
}

resource "helm_release" "sonarqube" {
  name             = "sonarqube"
  namespace        = "sonarqube"
  create_namespace = true

  repository = "https://sonarsource.github.io/helm-chart-sonarqube"
  chart      = "sonarqube"
  version    = "10.3.0"

  depends_on = [helm_release.prometheus_operator_crds]
  timeout    = var.helm_timeout

  values = [
    <<-EOF
    initSysctl:
      enabled: false
    elasticsearch:
      bootstrapChecks: false
    startupProbe:
      failureThreshold: 1000
    resources:
      requests:
        cpu: 0
        memory: 0
    persistence:
      enabled: true
    ingress:
      enabled: true
      hosts:
        - name: sonarqube.${var.domain}
      annotations:
        traefik.ingress.kubernetes.io/router.entrypoints: web,websecure
    prometheusMonitoring:
      podMonitor:
        enabled: true
        namespace: sonarqube
    EOF
  ]
}

resource "helm_release" "juice_shop" {
  name             = "juice-shop"
  namespace        = "juice-shop"
  create_namespace = true

  chart = "../charts/juice-shop"

  timeout = var.helm_timeout

  values = [
    <<-EOF
    ingress:
      host: juice-shop.${var.domain}
      annotations:
        traefik.ingress.kubernetes.io/router.entrypoints: web,websecure
        pod-security.kubernetes.io/enforce: baseline
    EOF
  ]
}
