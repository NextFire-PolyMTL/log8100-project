all: vagrant terraform

vagrant: Vagrantfile
	vagrant up

terraform: vagrant ansible/k3s.yaml terraform/secret.tfvars
	terraform -chdir=terraform init
	terraform -chdir=terraform apply -var-file=secret.tfvars

clean:
	vagrant destroy -f
	rm ansible/{agent-token,k3s.yaml}

.PHONY: all vagrant terraform clean
