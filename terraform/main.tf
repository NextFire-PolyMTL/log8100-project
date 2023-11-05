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
}

resource "helm_release" "kube_prometheus_stack" {
  name             = "kube-prometheus-stack"
  namespace        = "monitoring"
  create_namespace = true

  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "52.1.0"

  depends_on = [helm_release.prometheus_operator_crds]
  # this chart install takes a while, especially with trivy scanning
  timeout = 1800

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

  values = [
    <<-EOF
    serviceMonitor:
      enabled: true
    EOF
  ]
}
