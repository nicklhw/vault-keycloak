.DEFAULT_GOAL := all
.PHONY: all clean up-detach init logs ui tf-fmt tf-apply tf-destroy

VAULT_INIT_OUTPUT ?= ./docker-compose/scripts/vault.json
KEYCLOAK_ADMIN_USER ?= admin
KEYCLOAK_ADMIN_PASSWORD ?= passw0rd

all: clean up-detach init tf-apply restart-agent

up-detach:
	cd docker-compose \
	  && docker-compose up --detach

init:
	cd docker-compose/scripts \
	  && ./init.sh

clean: tf-destroy docker-down

docker-down:
	cd docker-compose \
	&& docker-compose down --volumes --remove-orphans \
	&& rm -f ./scripts/vault.json

restart-agent:
	docker restart vault-agent

logs:
	cd docker-compose \
    && docker-compose logs -f

ui:
	open http://localhost:8200

tf-fmt:
	terraform -chdir=./terraform fmt

tf-apply:
	@echo "vault_root_token = \"$$(cat ${VAULT_INIT_OUTPUT} | jq -r '.root_token')\"" > ./terraform/terraform.auto.tfvars
	@echo "keycloak_user = \"$(KEYCLOAK_ADMIN_USER)\"" >> ./terraform/terraform.auto.tfvars
	@echo "keycloak_password = \"$(KEYCLOAK_ADMIN_PASSWORD)\"" >> ./terraform/terraform.auto.tfvars
	terraform -chdir=./terraform init -upgrade
	terraform -chdir=./terraform apply -auto-approve

tf-destroy:
	terraform -chdir=./terraform init -upgrade
	terraform -chdir=./terraform destroy -auto-approve
	cd ./terraform && rm -rf *.terraform *.tfstate *.backup

kv-ui:
	open ./docker-compose/vault-agent/kv.html