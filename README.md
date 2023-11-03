# log8100-project

**Requirements:**

- VirtualBox
- `vagrant`
- `ansible`
- `terraform`
- `kubectl`
- `helm`

```sh
# Start both master and slave VMs and provision them with ansible
vagrant up

# Check that K3s is running correctly
KUBECONFIG=ansible/k3s.yaml kubectl get nodes -o wide
KUBECONFIG=ansible/k3s.yaml kubectl get pods -A -o wide -w

# Terraform the cluster
cd terraform/
terraform init
cp secret.tfvars.example secret.tfvars  # Edit secret.tfvars
terraform plan -var-file secret.tfvars  # Check
terraform apply -var-file secret.tfvars # Apply

# When done, destroy the VMs
vagrant destroy -f
```
