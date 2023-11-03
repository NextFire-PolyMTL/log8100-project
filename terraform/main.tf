provider "helm" {
  kubernetes {
    config_path = "../ansible/k3s.yaml"
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

  set {
    name  = "gitlabUrl"
    value = "https://gitlab.com"
  }

  set {
    name  = "rbac.create"
    value = "true"
  }

  set_sensitive {
    name  = "runnerToken"
    value = var.gitlabRunnerToken
  }
}
