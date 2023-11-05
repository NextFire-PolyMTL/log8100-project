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
# Create the VMs with Vagrant and provision them with Ansible and Terraform
make all

# To use kubectl, set the KUBECONFIG environment variable:
KUBECONFIG=ansible/k3s.yaml kubectl get nodes -o wide
KUBECONFIG=ansible/k3s.yaml kubectl get pods -A -o wide -w
```
