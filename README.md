Postfix Dovecot Cookbook
========================
[![Cookbook Version](https://img.shields.io/cookbook/v/postfix-dovecot.svg?style=flat)](https://supermarket.chef.io/cookbooks/postfix-dovecot)
[![Dependency Status](http://img.shields.io/gemnasium/zuazo/postfix-dovecot-cookbook.svg?style=flat)](https://gemnasium.com/zuazo/postfix-dovecot-cookbook)
[![Build Status](http://img.shields.io/travis/zuazo/postfix-dovecot-cookbook.svg?style=flat)](https://travis-ci.org/zuazo/postfix-dovecot-cookbook)

Installs and configures a mail server using [Postfix](http://www.postfix.org/), [Dovecot](http://www.dovecot.org/), [PostfixAdmin](http://postfixadmin.sourceforge.net/) and [SpamAssassin](http://spamassassin.apache.org/), including [Amazon SES](http://aws.amazon.com/ses/) support.

Requirements
============

## Supported Platforms

This cookbook has been tested on the following platforms:

* Amazon Linux
* CentOS `>= 6.0`
* Debian `>= 7.0`
* Fedora `>= 17.0`
* Ubuntu `>= 12.04`

Please, [let us know](https://github.com/zuazo/postfix-dovecot-cookbook/issues/new?title=I%20have%20used%20it%20successfully%20on%20...) if you use it successfully on any other platform.

## Required Cookbooks

* [dovecot](https://supermarket.chef.io/cookbooks/dovecot)
* [onddo-spamassassin](https://supermarket.chef.io/cookbooks/onddo-spamassassin)
* [postfixadmin](https://supermarket.chef.io/cookbooks/postfixadmin)
* [postfix-full](https://supermarket.chef.io/cookbooks/postfix-full) by [Malte Swart](https://github.com/mswart)
* [ssl_certificate](https://supermarket.chef.io/cookbooks/ssl_certificate)

## Required Applications

* Dovecot `>= 2`: requires this version of dovecot to be available by the distribution's package manager
* Ruby `>= 1.9.3`
* Chef `>= 11.14.2`

Attributes
==========

| Attribute                                         | Default                | Description                       |
|:--------------------------------------------------|:-----------------------|:----------------------------------|
| `node['postfix-dovecot']['postmaster_address']`   | `'postmaster@foo.bar'` | Postmaster mail address.
| `node['postfix-dovecot']['hostname']`             | `node['fqdn']`         | Hostname.
| `node['postfix-dovecot']['rbls']`                 | `[]`                   | Mail RBLs array.
| `node['postfix-dovecot']['database']['type']`     | `'mysql'`              | Database type. Possible values are: `'mysql'`, `'postgresql'` (Please, see [below](#postgresql-support)).
| `node['postfix-dovecot']['sieve']['enabled']`     | `true`                 | Whether to enable sieve.
| `node['postfix-dovecot']['sieve']['global_path']` | `"#{default['dovecot']['conf_path']}/sieve/default.sieve"` | Sieve global path.
| `node['postfix-dovecot']['spamc']['enabled']`     | `true`                 | Whether to enable SpamAssassin.
| `node['postfix-dovecot']['spamc']['recipe']`      | `'onddo-spamassassin'` | Spamc recipe name to use.
| `node['postfix-dovecot']['vmail']['user']`        | `'vmail'`              | Virtual mail system user name.
| `node['postfix-dovecot']['vmail']['group']`       | `node['postfix-dovecot']['vmail']['user']` | Virtual mail system group name.
| `node['postfix-dovecot']['vmail']['uid']`         | `5000`                 | Virtual mail system user id.
| `node['postfix-dovecot']['vmail']['gid']`         | `node['postfix-dovecot']['vmail']['uid']` | Virtual mail system group id.
| `node['postfix-dovecot']['vmail']['home']`        | `'/var/vmail'`         | Virtual mail user home path.

## Amazon SES Attributes

You can use `node['postfix-dovecot']['ses']['enabled']` to enable SES for sending emails.

| Attribute                                    | Default        | Description                       |
|:---------------------------------------------|:---------------|:----------------------------------|
| `node['postfix-dovecot']['ses']['enabled']`  | `false`        | Whether to enable [Amazon SES](http://aws.amazon.com/ses/).
| `node['postfix-dovecot']['ses']['source']`   | `'attributes'` | Where to read the credentials from. Possible values: `'attributes'`,  `'chef-vault'`.
| `node['postfix-dovecot']['ses']['vault']`    | `'amazon'`     | Chef Vault bag to read SES credentials from.
| `node['postfix-dovecot']['ses']['item']`     | `'ses'`        | Chef Vault item.
| `node['postfix-dovecot']['ses']['region']`   | `'us-east-1'`  | Amazon AWS region, used to calculate the servers.
| `node['postfix-dovecot']['ses']['servers']`  | *calculated*   | Amazon SES SMTP servers array.
| `node['postfix-dovecot']['ses']['username']` | `'USERNAME'`   | SES SMTP username. See [Obtaining Your Amazon SES SMTP Credentials](http://docs.aws.amazon.com/ses/latest/DeveloperGuide/smtp-credentials.html) documentation.
| `node['postfix-dovecot']['ses']['password']` | `'PASSWORD'`   | Amazon SES SMTP password.

When Chef Vault is disabled in `node['postfix-dovecot']['ses']['source']`, this is the default behavior, the credentials are read from `['username']` and `['password']` attributes.

When credentials should be read using `chef-vault`, the Chef Vault bag must have the following structure:

```json
{
  "username": "AMAZON_USERNAME",
  "password": "AMAZON_PASSWORD"
}
```

See the [Chef-Vault documentation](https://github.com/Nordstrom/chef-vault/blob/master/README.md) to learn how to create chef-vault bags.

## The SSL Certificate

This cookbook uses the [`ssl_certificate`](https://supermarket.chef.io/cookbooks/ssl_certificate) cookbook to create the SSL certificate. The namespace used is `node['postfix-dovecot']`. For example:

```ruby
node.default['postfix-dovecot']['common_name'] = 'mail.example.com'
include_recipe 'postfix-dovecot'
```

This certificate is used for Postfix and Dovecot. For PostfixAdmin, you should use the `node['postfixadmin']` namespace.

You can also tweak the supported SSL ciphers [setting the `node['ssl_certificate']['service']['compatibility']` attribute](https://github.com/zuazo/ssl_certificate-cookbook#securing-server-side-tls):

```ruby
node.default['ssl_certificate']['service']['compatibility'] = :modern

include_recipe 'postfix-dovecot'
```

See the [`ssl_certificate` namespace documentation](https://supermarket.chef.io/cookbooks/ssl_certificate#namespaces) for more information.

Recipes
=======

## postfix-dovecot::default

Installs and configures everything.

## postfix-dovecot::vmail

Creates vmail user.

## postfix-dovecot::spam

Installs and configures SpamAssassin.

## postfix-dovecot::postfix

Installs and configures Postfix.

## postfix-dovecot::postfix_mysql

Installs Postfix package with MySQL support. Used by the `postfix-dovecot::postfix` recipe.

## postfix-dovecot::postfix_postgresql

Installs Postfix package with PostgreSQL support. Used by the `postfix-dovecot::postfix` recipe.

## postfix-dovecot::postfixadmin

Installs and configures PostfixAdmin.

## postfix-dovecot::dovecot

Installs and configures Dovecot 2.

Usage Examples
==============

## Including in a Cookbook Recipe

Running it from a recipe:

```ruby
node['postfix-dovecot']['postmaster_address'] = 'postmaster@foobar.com'
node['postfix-dovecot']['hostname'] = 'mail.foobar.com'

include_recipe 'postfix-dovecot::default'

postfixadmin_admin 'admin@admindomain.com' do
  password 'sup3r-s3cr3t-p4ss'
  action :create
end

postfixadmin_domain 'foobar.com' do
  login_username 'admin@admindomain.com'
  login_password 'sup3r-s3cr3t-p4ss'
end

postfixadmin_mailbox 'bob@foobar.com' do
  password 'alice'
  login_username 'admin@admindomain.com'
  login_password 'sup3r-s3cr3t-p4ss'
end

postfixadmin_alias 'billing@foobar.com' do
  goto 'bob@foobar.com'
  login_username 'admin@admindomain.com'
  login_password 'sup3r-s3cr3t-p4ss'
end
```

Don't forget to include the `postfix-dovecot` cookbook as a dependency in the metadata.

```ruby
# metadata.rb
# [...]

depends 'postfix-dovecot'
```

## Including in the Run List

Another alternative is to include the default recipe in your *Run List*.

```json
{
  "name": "mail.example.com",
  [...]
  "run_list": [
    [...]
    "recipe[postfix-dovecot]"
  ]
}
```

## Enabling Some RBLs

You can enable some [RBLs](http://en.wikipedia.org/wiki/DNSBL) to avoid spam:

```ruby
node.default['postfix-dovecot']['rbls'] = %w(
  dnsbl.sorbs.net
  zen.spamhaus.org
  bl.spamcop.net
  cbl.abuseat.org
)
include_recipe 'postfix-dovecot::default'
```

PostgreSQL Support
==================

PostgreSQL support should be considered **experimental** at the moment. Use at your own risk.

[Any feedback you can provide regarding the PostgreSQL support](https://github.com/zuazo/postfix-dovecot-cookbook/issues/new?title=PostgreSQL%20Support) will be greatly appreciated.

## PostgreSQL Support on Debian and Ubuntu

Due to [`postgresql` cookbook issue #108](https://github.com/hw-cookbooks/postgresql/issues/108), you should configure your system locale correctly for PostgreSQL to work. You can use the `locale` cookbook to fix this. For example:

```ruby
ENV['LANGUAGE'] = ENV['LANG'] = node['locale']['lang']
ENV['LC_ALL'] = node['locale']['lang']
include_recipe 'locale'
# ...
node.default['postfix-dovecot']['database']['type'] = 'postgresql'
include_recipe 'postfix-dovecot'
```

## PostgreSQL Support on CentOS and Fedora

The latest CentOS and Fedora versions come without PostgreSQL support in their Postfix package. So we need to recompile it using the SRPM, enabling the PostgreSQL support.

The `postfix-dovecot::postfix_postgresql` recipe takes care of it transparently. This recipe has been tested using `test-kitchen`, but it may not work for all cases. This code has been tested in the following platforms:

* CentOS `6.5` and `7.0`
* Fedora `19` and `20`.

Please, [let us know](https://github.com/zuazo/postfix-dovecot-cookbook/issues/new?title=I%20have%20tested%20PostgreSQL%20support%20successfully%20on%20...) if you use PostgreSQL support successfully on any other platform.

## PostgreSQL Support on Amazon Linux

Support for PostgreSQL on Amazon Linux is still not finished because of the need to patch the provided SRPM. Its implementation would require a little monkey-patching.

Please, open an issue if [you need the support of PostgreSQL on Amazon Linux](https://github.com/zuazo/postfix-dovecot-cookbook/issues/new?title=We%20need%20PostgreSQL%20support%20on%20Amazon%20Linux).

## PostgreSQL Versions < 9.3

If you are using PostgreSQL version `< 9.3`, you may need to adjust the `shmmax` and `shmall` kernel parameters to configure the shared memory. You can see [the example used for the integration tests](test/cookbooks/postfix-dovecot_test/recipes/postgresql_memory.rb).

## PostgreSQL Support Related Attributes

Some cookbook attributes are used internally to add PostgreSQL support. They can make your journey smoother if you need to improve PostgreSQL support.

<table>
  <tr>
    <th>Attribute</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><code>node['postfix-dovecot']['yum']</code></td>
    <td>A list of yum repositories to add to include the source SRPMs.</td>
    <td><em>calculated</em></td>
  </tr>
  <tr>
    <td><code>node['postfix-dovecot']['postfix']['srpm']['packages']</code></td>
    <td>Packages required for compiling Postfix from sources.</td>
    <td><em>calculated</em></td>
  </tr>
  <tr>
    <td><code>node['postfix-dovecot']['postfix']['srpm']['rpm_regexp']</code></td>
    <td>An array with two values, a pattern and a replacement. This Regexp is used to get the final Postfix RPM name from the SRPM name.</td>
    <td><em>calculated</em></td>
  </tr>
  <tr>
    <td><code>node['postfix-dovecot']['postfix']['srpm']['rpm_build_args']</code></td>
    <td>A string with the arguments to pass to <em>rpmbuild</em> application. Normally contains the required option to enable PostgreSQL in the Postfix SRPM.</td>
    <td><em>calculated</em></td>
  </tr>
</table>

See the [attributes/postfix_postgresql.rb](/attributes/postfix_postgresql.rb) file for default examples.

Please do not hesitate [to make a PR](https://github.com/zuazo/postfix-dovecot-cookbook/blob/master/TESTING.md) if you improve the PostgreSQL support ;-)

Testing
=======

See [TESTING.md](https://github.com/zuazo/postfix-dovecot-cookbook/blob/master/TESTING.md).

Contributing
============

Please do not hesitate to [open an issue](https://github.com/zuazo/postfix-dovecot-cookbook/issues/new) with any questions or problems.

See [CONTRIBUTING.md](https://github.com/zuazo/postfix-dovecot-cookbook/blob/master/CONTRIBUTING.md).

TODO
====

See [TODO.md](https://github.com/zuazo/postfix-dovecot-cookbook/blob/master/TODO.md).


License and Author
==================

|                      |                                          |
|:---------------------|:-----------------------------------------|
| **Author:**          | [Xabier de Zuazo](https://github.com/zuazo) (<xabier@zuazo.org>)
| **Copyright:**       | Copyright (c) 2015, Xabier de Zuazo
| **Copyright:**       | Copyright (c) 2014-2015, Onddo Labs, SL.
| **License:**         | Apache License, Version 2.0

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at
    
        http://www.apache.org/licenses/LICENSE-2.0
    
    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
