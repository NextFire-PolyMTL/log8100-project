# log8100-project

**Requirements:**

- VirtualBox
- `vagrant`
- `ansible`
- `terraform`
- `kubectl`

```sh
# Start both master and slave VMs
vagrant up
# Check that k3s is running correctly
KUBECONFIG=ansible/k3s.yaml kubectl get nodes -o wide
KUBECONFIG=ansible/k3s.yaml kubectl get pods -A -o wide
# ...
# When done, destroy the VMs
vagrant destroy -f
```
