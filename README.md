# ForemanVault

[<img src="https://opensourcelogos.aws.dmtech.cloud/dmTECH_opensource_logo.svg" height="21" width="130">](https://www.dmtech.de/)

This is a plugin for Foreman that adds support for using credentials from Hashicorp Vault.

## Installation

See [Plugins install instructions](https://theforeman.org/plugins/) for how to install Foreman plugins.

## Usage

Setup Vault "Dev" mode:

```
$ brew install vault
$ vault server -dev
$ export VAULT_ADDR='http://127.0.0.1:8200'
$ vault secrets enable kv
```

To set up a connection between Foreman and Vault first navigate to the "Infrastructure" > "Vault Connections" menu and then hit the button labeled "Create Vault Connection". Now you should see a form. You have to fill in name, url and token (you can receive a token with the `$ vault token create -period=60m` command) and hit the "Submit" button.

You can now utilize two new macros in your templates:
 - vault_secret(vault_connection_name, secret_path)
 - vault_issue_certificate(vault_connection_name, pki_role_path, options...)

### vault_secret(vault_connection_name, secret_path)
To fetch secrets from Vault (you can write secrets with the `$ vault write kv/my_secret foo=bar` command), e.g.

```
<%= vault_secret('MyVault', 'kv/my_secret') %>
```

As result you should get secret data, e.g.

```
{:foo=>"bar"}
```

### vault_issue_certificate(vault_connection_name, pki_role_path, options...)
Issueing certificates is just as easy. Be sure to have a correctly set-up PKI, meaning, configure it so you can generate certificates from within the Vault UI. This means that you'll have had to set-up a CA or Intermediate CA. Once done, you can generate a certificate like this:


```
<%= vault_issue_certificate('MyVault', 'pkiEngine/issue/testRole', common_name: 'test.mydomain.com', ttl: '10s') %>
```

The common_name and ttl are optional, but there are [more options to configure](https://www.vaultproject.io/api/secret/pki/index.html#generate-certificate)

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
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.