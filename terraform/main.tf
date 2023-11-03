provider "helm" {
  kubernetes {
    config_path = "../ansible/k3s.yaml"
  }
}
