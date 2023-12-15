all: vagrant terraform

vagrant: Vagrantfile
	vagrant up

terraform: vagrant ansible/k3s.yaml terraform/secret.tfvars
	terraform -chdir=terraform init
	terraform -chdir=terraform apply -var-file=secret.tfvars -auto-approve -target=helm_release.sonarqube
	terraform -chdir=terraform apply -var-file=secret.tfvars -auto-approve

clean:
	vagrant destroy -f
	rm -f ansible/{agent-token,k3s.yaml}
	rm -f terraform/*.tfstate*

.PHONY: all vagrant terraform clean
