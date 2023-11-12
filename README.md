# log8100-project

**Requirements:**

- VirtualBox
- `vagrant`
- `ansible`
- `terraform`
- `kubectl`
- `helm`
- `make`

```sh
# Copy the example Terraform secret file and edit it
cp terraform/secret.tfvars.example terraform/secret.tfvars
vim terraform/secret.tfvars

# Create the VMs with Vagrant and provision them with Ansible and Terraform
make all

# To use kubectl, set the KUBECONFIG environment variable
export KUBECONFIG=ansible/k3s.yaml
kubectl get nodes -o wide
kubectl get pods -A -o wide
```
