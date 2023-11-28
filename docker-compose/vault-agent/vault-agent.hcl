pid_file = "./pidfile"

auto_auth {
  method {
    type = "approle"
    namespace = "demo"
    config = {
      role_id_file_path = "/vault-agent/app1_role_id"
      secret_id_file_path = "/vault-agent/app1_secret_id"
      secret_id_response_wrapping_path = "auth/approle/role/app1/secret-id"
    }
  }
}

template {
  source = "/vault-agent/kv.tpl"
  destination = "/vault-agent/kv.html"
}

vault {
  address = "http://vault:8200"
}
