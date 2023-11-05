variable "kubeconfig_path" {
  description = "Path to kubeconfig file"
  type        = string
  default     = "../ansible/k3s.yaml"
}

variable "domain" {
  description = "Base domain name"
  type        = string
  default     = "localhost"
}

variable "gitlab_runner_token" {
  description = "GitLab Runner Token"
  type        = string
  sensitive   = true
}
