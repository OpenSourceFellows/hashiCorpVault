ProgramEquity Vault Lab

In this Lab we will create primarily below Vault resources
JWT auth method
ROle for Github Actions
Policy for GitHub Actions
Static secrets engine
What is JWT Auth

The OIDC method allows authentication via a configured OIDC provider using the user's web browser. This method may be initiated from the Vault UI or the command line. Alternatively, a JWT can be provided directly. The JWT is cryptographically verified using locally-provided keys, or, if configured, an OIDC Discovery service can be used to fetch the appropriate keys. The choice of method is configured per role.
Configure JWT Auth

Enable JWT Auth

Enable the JWT auth method, and use write to apply the configuration to your Vault. For oidc_discovery_url and bound_issuer parameters, use https://token.actions.githubusercontent.com. These parameters allow the Vault server to verify the received JSON Web Tokens (JWT) during the authentication process.
vault auth enable jwt
Configure Auth method

vault write auth/jwt/config \
bound_issuer="https://token.actions.githubusercontent.com" \
oidc_discovery_url="https://token.actions.githubusercontent.com"
Configure roles to group different policies together. If the authentication is successful, these policies are attached to the resulting Vault access token

vault write auth/jwt/role/demo -<<EOF
{
 "role_type": "jwt",
 "user_claim": "workflow",
 "bound_claims": {
 "repository": "kalamabdul/Vault-intro"
},
"policies": ["app-policy"],
"ttl": "10m"
}
EOF
Secret Engines

Secrets engines are Vault components which store, generate or encrypt secrets
Types of Engines - KV store, dynamic creds, Encryption as service
Secret engines are plugins that need to be enabled, Community, Custom etc
Types of secrets engines
Ldap
Databases
KV engine
Demo for vault secrets engine - KV

Enable engine

vault secrets enable -path=secrets/hashi-corp-hackpod-test kv-v2
Add Static secrets

 vault kv put -mount=secrets/kv/ ait-12345/db password=supersecret
 vault kv put -mount=secrets/kv/ ait-56789/db password=supersecret
Read Static secrets

vault kv get -mount=secrets/kv/ ait-12345/db
vault kv get -mount=secrets/kv/ ait-56789/db
Vault Policies

Policies provide a declarative way to grant or forbid access to certain paths and operations in Vault
Policies are deny by default, so an empty policy grants no permission in the system
Pollicyworkflow

Demo for vault policy

Create Policy

#### *Configure a policy that only grants access to the specific paths your workflows will use to retrieve secrets*

tee app-policy.hcl <<EOF
path "secrets/hashi-corp-hackpod-test/*"
{  
capabilities = ["read"]
}
EOF
Sample GitHub Pipeline

    uses: hashicorp/vault-action@v2.4.0
    with:
      url: https://vault-public-vault-22deb760.8ee49bbe.z1.hashicorp.cloud:8200
      role: demo
      method: jwt
      namespace: "yournamespace"
# GitHub Action for Generating Software Bill of Materials (SBOM) with HashiCorp Vault

Creating a GitHub Action that uses HashiCorp Vault to generate Software Bill of Materials (SBOMs) involves several steps. SBOMs are typically used to document the components and dependencies in your software, and Vault can be used to store sensitive information like API keys or credentials securely. Here's a high-level overview of how you might approach this:

## Setting up HashiCorp Vault
1. **Set up HashiCorp Vault:** First, you'll need to set up and configure HashiCorp Vault with the necessary policies and access controls.

2. **Create a Vault token:** Create a Vault token with appropriate permissions to access secrets required for generating SBOMs.

3. **Store secrets in Vault:** Store the secrets needed for generating SBOMs securely in Vault.

## Creating a GitHub Action
4. **Create a GitHub Action:** Create a new GitHub Action workflow in your repository. This can be done by creating a `.github/workflows` directory and adding a YAML file, e.g., `generate_sbom.yml`.

## Configure the GitHub Action:
5. **Configure the GitHub Action:** Define the workflow triggers (e.g., on pushes, on a schedule, or manually).
6. Set up environment variables to securely retrieve secrets from Vault. You can use GitHub Secrets to store environment variables securely.

```yaml
on:
  push:
    branches:
      - main
env:
  VAULT_ADDR: ${{ secrets.VAULT_ADDR }}
  VAULT_TOKEN: ${{ secrets.VAULT_TOKEN }}
```
## Use Vault to retrieve secrets
7. **Use Vault to retrieve secrets:** Use the Vault token and the Vault API to retrieve the necessary secrets within your workflow. You can use the vault CLI tool or libraries like node-vault for Node.js or hvac for Python to interact with Vault.

```yaml
- name: Get secrets from Vault
  run: |
    vault login $VAULT_TOKEN
    VAULT_SECRET=$(vault read -field=secret secret/path/to/secrets)
```

## Generate and Publish the SBOM 
8. **Generate the SBOM:** Depending on your specific needs, you may need to run specific commands or scripts to generate your SBOMs. This could involve analyzing your software and its dependencies. Make sure the generated SBOM is stored in a format that can be easily consumed by other tools or shared with your team.

8. **Publish the SBOM:** Upload the generated SBOM to a secure location, such as an artifact repository or a cloud storage service. You can use GitHub Actions to upload files to your repository, external storage, or even as GitHub releases.


## Example GitHub Action Workflow
Here's an example of a simplified GitHub Action workflow:
```yaml
name: Generate SBOM
on:
  push:
    branches:
      - main
env:
  VAULT_ADDR: ${{ secrets.VAULT_ADDR }}
  VAULT_TOKEN: ${{ secrets.VAULT_TOKEN }}
jobs:
  generate-sbom:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v2
      - name: Get secrets from Vault
        run: |
          vault login $VAULT_TOKEN
          VAULT_SECRET=$(vault read -field=secret secret/path/to/secrets)
      - name: Generate SBOM
        run: |
          # Add your SBOM generation logic here
      - name: Upload SBOM
        uses: actions/upload-artifact@v2
        with:
          name: sbom
          path: path/to/sbom.xml
```
Please note that this is a simplified example, and you should adapt it to your specific requirements and tools for generating SBOMs. Additionally, ensure that your secrets and generated SBOM are handled securely and according to your organization's security policies.
