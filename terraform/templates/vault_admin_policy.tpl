# Create and manage ACL policies broadly across Vault
# List existing policies
path "sys/policies/acl"
{
  capabilities = ["list"]
}

# Create and manage ACL policies
path "sys/policies/acl/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Enable and manage authentication methods broadly across Vault # Manage auth methods broadly across Vault
path "auth/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Create, update, and delete auth methods
path "sys/auth/*"
{
  capabilities = ["create", "update", "delete", "sudo"]
}

# List auth methods
path "sys/auth"
{
  capabilities = ["read"]
}

# Enable and manage the key/value secrets engine at `secret/` path # List, create, update, and delete key/value secrets
path "secret/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Allow managing leases
path "sys/leases/*"
{
  capabilities = ["read", "update", "list"]
}

# Allow managing identities
path "identity/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Manage namespaces
path "sys/namespaces/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Manage secrets engines
path "sys/mounts/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# List existing secrets engines.
path "sys/mounts"
{
  capabilities = ["read"]
}

# Configure License
path "sys/license"
{
  capabilities = ["create", "read", "update", "delete", "list"]
}

# Initialise Vault
path "sys/init"
{
  capabilities = ["create", "read", "update"]
}

# Configure Vault UI
path "sys/config/ui"
{
  capabilities = ["read", "update", "delete", "list"]
}