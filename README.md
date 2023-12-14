# log8100-project

## Requirements

- VirtualBox
- `vagrant`
- `ansible`
- `terraform`
- `kubectl`
- `helm`
- `make`

### macOS

Using [Homebrew](https://brew.sh):

```sh
brew install ansible terraform kubectl helm
brew install --cask vagrant virtualbox
```

### Arch Linux

```sh
sudo pacman -S virtualbox vagrant ansible terraform kubectl helm base-devel
```

## Usage

The default Vagrant configuration setups the master VM with 2 CPUs + 4 GB of RAM and the slave VM with 4 CPUs + 6 GB of RAM for optimal performances. You can change these values in the `Vagrantfile` if needed.

```sh
# Copy the example Terraform secret file and edit it
cp terraform/secret.tfvars.example terraform/secret.tfvars
$EDITOR terraform/secret.tfvars

# Create the VMs with Vagrant and provision them with Ansible and Terraform
# (can take up to 30 min)
make all

# To use kubectl, set the KUBECONFIG environment variable
export KUBECONFIG=ansible/k3s.yaml
kubectl get nodes -o wide
kubectl get pods -A -o wide

# Destroy everything
make clean
```

Using the default `domain` Terraform variable, applications will be deployed on `localhost` at:

- Prometheus: http://prometheus.localhost:8080
- Alert Manager: http://alertmanager.localhost:8080
- Grafana: http://grafana.localhost:8080
- Sonarqube: http://sonarqube.localhost:8080
- Juice Shop: http://juice-shop.localhost:8080
