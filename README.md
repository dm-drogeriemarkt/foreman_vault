# ForemanVault

This is a plugin for Foreman that adds support for using credentials from Hashicorp Vault.

## Installation

See [How_to_Install_a_Plugin](http://projects.theforeman.org/projects/foreman/wiki/How_to_Install_a_Plugin)
for how to install Foreman plugins

## Usage

Setup Vault "Dev" mode:

```
$ brew install vault
$ vault server -dev
$ export VAULT_ADDR='http://127.0.0.1:8200'
$ vault secrets enable kv
```

To set up a connection between Foreman and Vault first navigate to the "Infrastructure" > "Vault Connections" menu and then hit the button labeled "Create Vault Connection". Now you should see a form. You have to fill in name, url and token(you can receive token with the `$ vault token create -period=60m` command) and hit "Submit" button.

You can now use `vault_secret(vault_connection_name, secret_path)` macro in your templates to fetch secrets from Vault(you can write secrets with the `$ vault write kv/my_secret foo=bar` command), e.g.

```
<%= vault_secret('MyVault', 'kv/my_secret') %>
```

As result you should get secret data, e.g.

```
{:foo=>"bar"}
```

## Contributing

Fork and send a Pull Request. Thanks!

## Copyright

Copyright (c) 2018 dm-drogerie markt GmbH & Co. KG https://dm.de

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
