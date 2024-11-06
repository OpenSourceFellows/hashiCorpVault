

path "ldap/static-cred/12345-serviceaccount1" {
  capabilities = ["read"]
}
path "secrets/kv/data/ait-12345/*" {
  capabilities = ["read"]
}