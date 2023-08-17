# Vault Keycloak OIDC Integration

# Prerequisites
- [Docker Desktop](https://www.docker.com/products/docker-desktop/)

# Run

```shell
# export Vault license
export VAULT_LICENSE=$(cat ~/Downloads/vault.hclic)     

# Start all containers
make all

# open demo-ui
make ui

# Login to Vault as admin
export VAULT_ADDR=http://localhost:8200
vault login --method=userpass username=admin password=passw0rd
```

# Useful commands


# Reference
- [Running Keycload in a container](https://github.com/eabykov/keycloak-compose/tree/main)