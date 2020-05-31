# ForemanVault

[<img src="https://opensourcelogos.aws.dmtech.cloud/dmTECH_opensource_logo.svg" height="21" width="130">](https://www.dmtech.de/)

**Foreman Vault** is a plugin for Foreman that integrates with Hashicorp Vault for different things. Currently, it offers two distinct features.

## 1. Vault secrets in Foreman templates

This adds two new macros which can be used in Foreman templates:

- `vault_secret` - Retreive secrets at a given Vault path
- `vault_issue_certificate` - Issues new certificates

## 2. Management of Vault Policies and AuthMethods

Vault [policies](https://www.vaultproject.io/docs/concepts/policies) and [auth methods](https://www.vaultproject.io/docs/concepts/auth) (of type _cert_) can be created automatically as part of the **host orchestration**.
Auth methods also get deleted after the host is removed from Foreman.

This allows Foreman to create everything needed to access Hashicorp Vault directly from a VM using it's Puppet certificate (e.g. for _Deferred functions_ in Puppet or other CLI tools).

## Requirements

- Foreman >= 1.20
- Working Vault instance
  - with _cert_ auth enabled
  - with _kv_ secret store enabled
- valid Vault Token

**Dev Vault Instance**

To run a local Vault dev environment on MacOS use:

```
$ brew install vault
$ vault server -dev
$ export VAULT_ADDR='http://127.0.0.1:8200'
$ vault secrets enable kv
$ vault auth enable cert

$ vault token create -period=60m
[...]
```

## Installation

See [Plugins install instructions](https://theforeman.org/plugins/) for how to install Foreman plugins.

## Basic configuration

To create a new Vault connection navigate to `Infrastructure -> Vault Connections` and hit the `Create Vault Connection` button. There you can enter a name, the Vault URL and a secret token.

## Vault secrets in templates

At this point you can utilize two new macros in your templates:

- vault_secret(vault_connection_name, secret_path)
- vault_issue_certificate(vault_connection_name, pki_role_path, options...)

### vault_secret(vault_connection_name, secret_path)

To fetch secrets from Vault (you can write secrets with the `vault write kv/my_secret foo=bar` command), e.g.

```
<%= vault_secret('MyVault', 'kv/my_secret') %>
```

As result you should get secret data, e.g.

```
{:foo=>"bar"}
```

### vault_issue_certificate(vault_connection_name, pki_role_path, options...)

Issueing certificates is just as easy. Be sure to have a correctly set-up PKI, meaning, configure it so you can generate certificates from within the Vault UI. This means that you'll have to set-up a CA or Intermediate CA. Once done, you can generate a certificate like this:

```
<%= vault_issue_certificate('MyVault', 'pkiEngine/issue/testRole', common_name: 'test.mydomain.com', ttl: '10s') %>
```

The _common_name_ and _ttl_ are optional, but there are [more options to configure](https://www.vaultproject.io/api/secret/pki/index.html#generate-certificate)

## Vault policies and auth methods

### Policies

The policy is based on a new template kind `VaultPolicy` which is basically a [Vault Policy](https://www.vaultproject.io/docs/concepts/policies#policy-syntax) extended with ERB.

The name of the policy is extracted from a _Magic comment_ within the template. Therefore you can use ERB to influence the name:

```
# NAME: <%= @host.owner %>-<%= @host.environment %>

path "secret/foo" {
  capabilities = ["read"]
}
```

You can create multiple `VaultPolicy` templates and configure the default policy used in host orchestration by setting the Foreman Setting `vault_policy_template` to the desired one.

**Note: If the policy renders empty (yes, you can use conditions within ERB), the orchestration is skipped!**

### Auth methods

[Auth methods of type `cert`](https://www.vaultproject.io/docs/auth/cert) are created with three attributes:

- **certificate**: content of the Foreman setting `ssl_ca_file`
- **allowed_common_names**: FQDN of the host which triggered the orchestration
- **token_policies**: This is automatically linked to the policy from above

## Contributing

Fork and send a Pull Request. Thanks!

## Copyright

Copyright (c) 2018-2020 dmTECH GmbH, [dmtech.de](https://www.dmtech.de/)

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <http://www.gnu.org/licenses/>.
