#------------------------------------------------------------------------------#
# Namespace config
#------------------------------------------------------------------------------#
resource "vault_namespace" "demo" {
  path = "demo"
}

#------------------------------------------------------------------------------#
# KV engine config
#------------------------------------------------------------------------------#
resource "vault_mount" "kvv2" {
  namespace   = vault_namespace.demo.path
  path        = "secret"
  type        = "kv"
  options     = { version = "2" }
  description = "KV Version 2 secret engine mount"
}

resource "vault_kv_secret_v2" "app1_secret" {
  namespace           = vault_namespace.demo.path
  mount               = vault_mount.kvv2.path
  name                = "app1"
  cas                 = 1
  delete_all_versions = true
  data_json = jsonencode(
    {
      zip = "zap",
      foo = "bar"
    }
  )
}

resource "vault_kv_secret_v2" "app2_secret" {
  namespace           = vault_namespace.demo.path
  mount               = vault_mount.kvv2.path
  name                = "app2"
  cas                 = 1
  delete_all_versions = true
  data_json = jsonencode(
    {
      zip = "zap",
      foo = "bar"
    }
  )
}

#------------------------------------------------------------------------------#
# OIDC client root namespace
#------------------------------------------------------------------------------#

resource "vault_identity_oidc_key" "keycloak_provider_key_root" {
  name      = "keycloak"
  algorithm = "RS256"
}

resource "vault_jwt_auth_backend" "keycloak_root" {
  path               = "oidc"
  type               = "oidc"
  default_role       = "default"
  oidc_discovery_url = format("http://keycloak:8080/realms/%s", keycloak_realm.realm.id)
  oidc_client_id     = keycloak_openid_client.openid_client.client_id
  oidc_client_secret = keycloak_openid_client.openid_client.client_secret

  tune {
    audit_non_hmac_request_keys  = []
    audit_non_hmac_response_keys = []
    default_lease_ttl            = "1h"
    listing_visibility           = "unauth"
    max_lease_ttl                = "1h"
    passthrough_request_headers  = []
    token_type                   = "default-service"
  }
}

resource "vault_jwt_auth_backend_role" "default_root" {
  backend         = vault_jwt_auth_backend.keycloak.path
  role_name       = "default"
  token_ttl       = 3600
  token_max_ttl   = 3600
  token_policies  = ["default"]
  bound_audiences = [keycloak_openid_client.openid_client.client_id]
  user_claim      = "email"
  claim_mappings = {
    preferred_username = "username"
    email              = "email"
  }
  role_type             = "oidc"
  allowed_redirect_uris = ["http://localhost:8200/ui/vault/auth/oidc/oidc/callback", "http://localhost:8250/oidc/callback"]
  groups_claim          = format("/resource_access/%s/roles", keycloak_openid_client.openid_client.client_id)
}



#------------------------------------------------------------------------------#
# OIDC client demo namespace
#------------------------------------------------------------------------------#

resource "vault_identity_oidc_key" "keycloak_provider_key" {
  namespace = vault_namespace.demo.path
  name      = "keycloak"
  algorithm = "RS256"
}

resource "vault_jwt_auth_backend" "keycloak" {
  namespace          = vault_namespace.demo.path
  path               = "oidc"
  type               = "oidc"
  default_role       = "default"
  oidc_discovery_url = format("http://keycloak:8080/realms/%s", keycloak_realm.realm.id)
  oidc_client_id     = keycloak_openid_client.openid_client.client_id
  oidc_client_secret = keycloak_openid_client.openid_client.client_secret

  tune {
    audit_non_hmac_request_keys  = []
    audit_non_hmac_response_keys = []
    default_lease_ttl            = "1h"
    listing_visibility           = "unauth"
    max_lease_ttl                = "1h"
    passthrough_request_headers  = []
    token_type                   = "default-service"
  }
}

resource "vault_jwt_auth_backend_role" "default" {
  namespace       = vault_namespace.demo.path
  backend         = vault_jwt_auth_backend.keycloak.path
  role_name       = "default"
  token_ttl       = 3600
  token_max_ttl   = 3600
  token_policies  = ["default"]
  bound_audiences = [keycloak_openid_client.openid_client.client_id]
  user_claim      = "email"
  claim_mappings = {
    preferred_username = "username"
    email              = "email"
  }
  role_type             = "oidc"
  allowed_redirect_uris = ["http://localhost:8200/ui/vault/auth/oidc/oidc/callback", "http://localhost:8250/oidc/callback"]
  groups_claim          = format("/resource_access/%s/roles", keycloak_openid_client.openid_client.client_id)
}

#------------------------------------------------------------------------------#
# Vault policies
#------------------------------------------------------------------------------#
data "template_file" "vault_super_admin_policy" {
  template = file("${path.module}/templates/vault_super_admin_policy.tpl")
}

data "template_file" "vault_admin_policy" {
  template = file("${path.module}/templates/vault_admin_policy.tpl")
}

resource "vault_policy" "vault_super_admin" {
  name   = "vault-super-admin"
  policy = data.template_file.vault_super_admin_policy.rendered
}

resource "vault_policy" "vault_admin" {
  namespace = vault_namespace.demo.path
  name      = "vault-admin"
  policy    = data.template_file.vault_admin_policy.rendered
}

data "template_file" "app1_owner_policy" {
  template = file("${path.module}/templates/app1_owner_policy.tpl")
}

resource "vault_policy" "app1_owner_policy" {
  namespace = vault_namespace.demo.path
  name      = "app1-owner"
  policy    = data.template_file.app1_owner_policy.rendered
}

data "template_file" "app2_owner_policy" {
  template = file("${path.module}/templates/app2_owner_policy.tpl")
}

resource "vault_policy" "app2_owner_policy" {
  namespace = vault_namespace.demo.path
  name      = "app2-owner"
  policy    = data.template_file.app2_owner_policy.rendered
}

#------------------------------------------------------------------------------#
# Vault external groups
#------------------------------------------------------------------------------#
resource "vault_identity_group" "vault_super_admin_group" {
  name = "vault-super-admin"
  type = "external"
  policies = [
    vault_policy.vault_super_admin.name
  ]
}

resource "vault_identity_group_alias" "vault_super_admin_group_alias" {
  name           = "vault-super-admin"
  mount_accessor = vault_jwt_auth_backend.keycloak_root.accessor
  canonical_id   = vault_identity_group.vault_super_admin_group.id
}


resource "vault_identity_group" "vault_admin_group" {
  namespace = vault_namespace.demo.path
  name      = "vault-admin"
  type      = "external"
  policies = [
    vault_policy.vault_admin.name
  ]
}

resource "vault_identity_group_alias" "vault_admin_group_alias" {
  namespace      = vault_namespace.demo.path
  name           = "vault-admin"
  mount_accessor = vault_jwt_auth_backend.keycloak.accessor
  canonical_id   = vault_identity_group.vault_admin_group.id
}

resource "vault_identity_group" "app1_owner_group" {
  namespace = vault_namespace.demo.path
  name      = "app1-owner"
  type      = "external"
  metadata = {
    app-name = "app1"
  }
  policies = [
    vault_policy.app1_owner_policy.name
  ]
}

resource "vault_identity_group_alias" "app1_owner_group_alias" {
  namespace      = vault_namespace.demo.path
  name           = "app1-owner"
  mount_accessor = vault_jwt_auth_backend.keycloak.accessor
  canonical_id   = vault_identity_group.app1_owner_group.id
}

resource "vault_identity_group" "app2_owner_group" {
  namespace = vault_namespace.demo.path
  name      = "app2-owner"
  type      = "external"
  metadata = {
    app-name = "app2"
  }
  policies = [
    vault_policy.app2_owner_policy.name
  ]
}

resource "vault_identity_group_alias" "app2_owner_group_alias" {
  namespace      = vault_namespace.demo.path
  name           = "app2-owner"
  mount_accessor = vault_jwt_auth_backend.keycloak.accessor
  canonical_id   = vault_identity_group.app2_owner_group.id
}