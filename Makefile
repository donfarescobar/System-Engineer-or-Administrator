# Validasi & lint lokal. Dipakai juga oleh pipeline CI (.github/workflows).

.PHONY: help lint tf-validate ansible-check k8s-lint validate clean

help:
	@echo "Target:"
	@echo "  lint         yamllint semua file YAML"
	@echo "  tf-validate  terraform fmt + init + validate"
	@echo "  ansible-check ansible-playbook --syntax-check"
	@echo "  k8s-lint     yamllint manifest kubernetes"
	@echo "  validate     semua check di atas"
	@echo "  clean        hapus artefak terraform lokal"

lint:
	yamllint .

tf-validate:
	terraform -chdir=terraform fmt -check -recursive
	terraform -chdir=terraform init -backend=false -input=false -no-color
	terraform -chdir=terraform validate -no-color

ansible-check:
	ansible-playbook -i ansible/inventory/example.ini \
		--syntax-check ansible/hardening-playbook.yml

k8s-lint:
	yamllint kubernetes/

validate: lint tf-validate ansible-check k8s-lint

clean:
	rm -rf terraform/.terraform terraform/terraform.tfstate* .terraform*