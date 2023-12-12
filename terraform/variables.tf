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

variable "helm_timeout" {
  description = "Chart install timeout"
  type        = number
  default     = 3600
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

variable "alertmanager_slack_api_url" {
  description = "Alertmanager Slack API URL"
  type        = string
  sensitive   = true
}

variable "grafana_admin_password" {
  description = "Grafana Admin Password"
  type        = string
  sensitive   = true
}
