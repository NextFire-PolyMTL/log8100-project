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
  version    = 0.58

  values = [
    <<-EOF
    gitlabUrl: https://gitlab.com
    rbac:
      create: true
    EOF
  ]

  set_sensitive {
    name  = "runnerToken"
    value = var.gitlab_runner_token
  }
}
