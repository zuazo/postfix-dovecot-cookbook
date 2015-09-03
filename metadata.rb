# encoding: UTF-8
#
# Cookbook Name:: postfix-dovecot
# Author:: Xabier de Zuazo (<xabier@zuazo.org>)
# Copyright:: Copyright (c) 2013-2015 Onddo Labs, SL.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

name 'postfix-dovecot'
maintainer 'Xabier de Zuazo'
maintainer_email 'xabier@zuazo.org'
license 'Apache 2.0'
description 'Installs and configures a mail server using Postfix, Dovecot, '\
            'PostfixAdmin and SpamAssassin, including Amazon SES support.'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '2.0.1'

if respond_to?(:source_url)
  source_url "https://github.com/zuazo/#{name}-cookbook"
end
if respond_to?(:issues_url)
  issues_url "https://github.com/zuazo/#{name}-cookbook/issues"
end

supports 'amazon'
supports 'centos', '>= 6.0'
supports 'debian', '>= 7.0'
supports 'fedora', '>= 17.0'
supports 'ubuntu', '>= 12.04'

recipe 'postfix-dovecot::default', 'Installs and configures everything.'
recipe 'postfix-dovecot::vmail', 'Creates vmail user.'
recipe 'postfix-dovecot::spam', 'Installs and configures SpamAssassin.'
recipe 'postfix-dovecot::postfix', 'Installs and configures Postfix.'
recipe 'postfix-dovecot::postfix_mysql',
       'Installs Postfix package with MySQL support.'
recipe 'postfix-dovecot::postfix_postgresql',
       'Installs Postfix package with PostgreSQL support.'
recipe 'postfix-dovecot::postfixadmin', 'Installs and configures PostfixAdmin.'
recipe 'postfix-dovecot::dovecot', 'Installs and configures Dovecot 2.'

depends 'chef-vault', '~> 1.1'
depends 'dovecot', '~> 2.0'
depends 'onddo-spamassassin', '~> 1.0'
depends 'postfixadmin', '~> 2.0'
depends 'postfix-full', '~> 0.1'
depends 'ssl_certificate', '~> 1.2'
depends 'yum', '~> 3.0'

attribute 'postfix-dovecot/postmaster_address',
          display_name: 'postmaster address',
          description: 'Postmaster mail address.',
          type: 'string',
          required: 'recommended',
          default: 'postmaster@foo.bar'

attribute 'postfix-dovecot/rbls',
          display_name: 'postfix rbls',
          description: 'Mail RBLs array.',
          type: 'array',
          required: 'recommended',
          default: []

attribute 'postfix-dovecot/hostname',
          display_name: 'hostname',
          description: 'Hostname.',
          type: 'string',
          required: 'recommended',
          calculated: true

grouping 'postfix-dovecot/database',
         title: 'postfix database',
         description: 'Postfix database configuration options'

attribute 'postfix-dovecot/database/type',
          display_name: 'postfix database type',
          description: 'Postfix database type.',
          choice: %w(mysql postgresql),
          type: 'string',
          required: 'optional',
          default: 'mysql'

grouping 'postfix-dovecot/sieve',
         title: 'sieve configuration',
         description: 'Sieve configuration.'

attribute 'postfix-dovecot/sieve/enabled',
          display_name: 'sieve enabled',
          description: 'Whether to enable sieve.',
          type: 'string',
          choice: %w(true false),
          required: 'recommended',
          default: 'true'

attribute 'postfix-dovecot/sieve/global_path',
          display_name: 'sieve global_path',
          description: 'Sieve global path.',
          type: 'string',
          required: 'optional',
          calculated: true

grouping 'postfix-dovecot/spamc',
         title: 'spamc configuration',
         description: 'Spamc configuration.'

attribute 'postfix-dovecot/spamc/enabled',
          display_name: 'spamc enabled',
          description: 'Whether to enable SpamAssassin.',
          type: 'string',
          choice: %w(true false),
          required: 'optional',
          default: 'true'

attribute 'postfix-dovecot/spamc/recipe',
          display_name: 'spamc recipe',
          description: 'Spamc recipe name to use.',
          type: 'string',
          required: 'optional',
          default: 'onddo-spamassassin'

grouping 'postfix-dovecot/vmail',
         title: 'vmail configuration',
         description: 'Virtual mail system user configuration.'

attribute 'postfix-dovecot/vmail/user',
          display_name: 'vmail user',
          description: 'Virtual mail system user name.',
          type: 'string',
          required: 'optional',
          default: 'vmail'

attribute 'postfix-dovecot/vmail/group',
          display_name: 'vmail group',
          description: 'Virtual mail system group name.',
          type: 'string',
          required: 'optional',
          calculated: true

attribute 'postfix-dovecot/vmail/uid',
          display_name: 'vmail uid',
          description: 'Virtual mail system user id.',
          type: 'string',
          required: 'optional',
          default: '5000'

attribute 'postfix-dovecot/vmail/gid',
          display_name: 'vmail gid',
          description: 'Virtual mail system group id.',
          type: 'string',
          required: 'optional',
          calculated: true

attribute 'postfix-dovecot/vmail/home',
          display_name: 'vmail home',
          description: 'Virtual mail user home path.',
          type: 'string',
          required: 'optional',
          default: '/var/vmail'

attribute 'postfix-dovecot/ses/enabled',
          display_name: 'ses enabled',
          description: 'Whether to enable Amazon SES.',
          type: 'string',
          choice: %w(true false),
          required: 'recommended',
          default: 'false'

attribute 'postfix-dovecot/ses/source',
          display_name: 'ses credentials source',
          description: 'Where to read the credentials from.',
          type: 'string',
          choice: %w(attributes chef-vault),
          required: 'recommended',
          default: 'attributes'

attribute 'postfix-dovecot/ses/vault',
          display_name: 'ses credentials vault',
          description: 'Chef Vault bag to read SES credentials from.',
          type: 'string',
          required: 'recommended',
          default: 'amazon'

attribute 'postfix-dovecot/ses/item',
          display_name: 'ses credentials vault item',
          description: 'Chef Vault item.',
          type: 'string',
          required: 'recommended',
          default: 'ses'

attribute 'postfix-dovecot/ses/region',
          display_name: 'ses region',
          description: 'Amazon AWS region, used to calculate the servers.',
          type: 'string',
          required: 'optional',
          default: 'us-east-1'

attribute 'postfix-dovecot/ses/servers',
          display_name: 'ses servers',
          description: 'Amazon SES SMTP servers.',
          type: 'array',
          required: 'optional',
          default: %w(
            email-smtp.us-east-1.amazonaws.com:25
            ses-smtp-prod-335357831.us-east-1.elb.amazonaws.com:25
          )

attribute 'postfix-dovecot/ses/username',
          display_name: 'ses username',
          description: 'Amazon SES SMTP username.',
          type: 'string',
          required: 'recommended',
          default: 'USERNAME'

attribute 'postfix-dovecot/ses/password',
          display_name: 'ses password',
          description: 'Amazon SES SMTP password.',
          type: 'string',
          required: 'recommended',
          default: 'PASSWORD'

attribute 'postfix-dovecot/yum',
          display_name: 'yum repositories',
          description:
            'A list of yum repositories to add to include the source SRPMs.',
          type: 'hash',
          required: 'optional',
          calculated: true

attribute 'postfix-dovecot/srpm/packages',
          display_name: 'srpm packages',
          description: 'Packages required for compiling Postfix from sources.',
          type: 'array',
          required: 'optional',
          calculated: true

attribute 'postfix-dovecot/srpm/rpm_regexp',
          display_name: 'srpm rpm regexp',
          description:
            'An array with two values, a pattern and a replacement. This'\
            'Regexp is used to get the final Postfix RPM name from the SRPM '\
            'name.',
          type: 'array',
          required: 'optional',
          calculated: true

attribute 'postfix-dovecot/srpm/rpm_regexp',
          display_name: 'srpm rpm regexp',
          description:
            'A string with the arguments to pass to rpmbuild application. '\
            'Normally contains the required option to enable PostgreSQL in '\
            'the Postfix SRPM.',
          type: 'hash',
          required: 'optional',
          calculated: true
