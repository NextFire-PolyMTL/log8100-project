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

variable "alertmanager_discord_webhook_url" {
  description = "Alertmanager Discord Webhook URL"
  type        = string
  sensitive   = true
}

variable "grafana_admin_password" {
  description = "Grafana Admin Password"
  type        = string
  sensitive   = true
}
