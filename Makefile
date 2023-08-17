.DEFAULT_GOAL := all
.PHONY: all clean up-detach init logs ui

export VAULT_ADDR := http://localhost:8200

all: clean up-detach init

up-detach:
	cd docker-compose \
	  && docker-compose up --detach

init:
	cd docker-compose/scripts \
	  && ./init.sh

clean:
	cd docker-compose \
	&& docker-compose down --volumes --remove-orphans \
	&& rm -f ./scripts/vault.json

logs:
	cd docker-compose \
    && docker-compose logs -f

ui:
	open http://localhost:7071