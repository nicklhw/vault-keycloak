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

# Login to KeyCloak UI
http://localhost:8080
admin/passw0rd
```

# Useful commands


# Reference
- [Running Keycload in a container](https://github.com/eabykov/keycloak-compose/tree/main)
- [Vault OIDC auth method](https://developer.hashicorp.com/vault/tutorials/auth-methods/oidc-auth)
- [Keycloak server administration guide](https://www.keycloak.org/docs/latest/server_admin/#keycloak-features-and-concepts)
- [Integrate Keycloak with Vault](https://github.com/PacoVK/keycloak-vault/tree/master)