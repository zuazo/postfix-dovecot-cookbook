#
# Cookbook Name:: postfix-dovecot
# Recipe:: dovecot
#
# Copyright 2013, Onddo Labs, Sl.
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

node.default['dovecot']['conf_files_group'] = node['postfix-dovecot']['vmail']['user']

node.default['dovecot']['conf']['disable_plaintext_auth'] = false
node.default['dovecot']['conf_files_mode'] = '00640'

# 10-logging.conf
node.default['dovecot']['conf']['log_path'] = 'syslog'
node.default['dovecot']['conf']['syslog_facility'] = 'mail'
node.default['dovecot']['conf']['log_timestamp'] = '"%Y-%m-%d %H:%M:%S"'

# 10-mail.conf
node.default['dovecot']['conf']['mail_location'] = 'maildir:~/Maildir'
node.default['dovecot']['conf']['mail_privileged_group'] = 'mail'

# 10-master.conf
node.default['dovecot']['services']['auth']['listeners'] = [
  # auth_socket_path points to this userdb socket by default. It's typically
  # used by dovecot-lda, doveadm, possibly imap process, etc. Its default
  # permissions make it readable only by root, but you may need to relax these
  # permissions. Users that have access to this socket are able to get a list
  # of all usernames and get results of everyone's userdb lookups.
  { 'unix:auth-userdb' => {
    'mode' => '0600',
    'user' => node['postfix-dovecot']['vmail']['user'],
    'group' => node['postfix-dovecot']['vmail']['group'],
  } },
  # Postfix smtp-auth
  { 'unix:/var/spool/postfix/private/auth' => {
    # TODO reinforcing this
    'mode' => '0666',
    'user' => 'postfix',
    'group' => 'postfix',
  } },
]

# 15-lda.conf
node.default['dovecot']['conf']['postmaster_address'] = node['postfix-dovecot']['postmaster_address']
node.default['dovecot']['conf']['hostname'] = node['postfix-dovecot']['hostname']
node.default['dovecot']['conf']['lda_mailbox_autocreate'] = true
node.default['dovecot']['conf']['lda_mailbox_autosubscribe'] = true
if node['postfix-dovecot']['sieve']['enabled']
  node.default['dovecot']['protocols']['lda']['mail_plugins'] = [ '$mail_plugins', 'sieve' ]
else
  node.default['dovecot']['protocols']['lda']['mail_plugins'] = [ '$mail_plugins' ] # not required
end

# 20-imap.conf
node.default['dovecot']['protocols']['imap'] = {}

# 90-sieve.conf
if node['postfix-dovecot']['sieve']['enabled']
  node.default['dovecot']['plugins']['sieve']['sieve_global_path'] = node['postfix-dovecot']['sieve']['global_path']
end

# auth-sql.conf.ext
node.default['dovecot']['auth']['sql']['passdb']['args'] = '/etc/dovecot/dovecot-sql.conf.ext'
node.default['dovecot']['auth']['sql']['userdb']['args'] = '/etc/dovecot/dovecot-sql.conf.ext'

# auth-static.conf.ext
node.default['dovecot']['auth']['static']['userdb']['args'] = [
  "uid=#{node['postfix-dovecot']['vmail']['user']}",
  "gid=#{node['postfix-dovecot']['vmail']['group']}",
  "home=#{node['postfix-dovecot']['vmail']['home']}/%d/%n",
  'allow_all_users=yes',
]

# auth-system.conf.ext
node.default['dovecot']['auth']['system'] = {}

# dovecot-sql.conf.ext
node.default['dovecot']['conf']['sql']['driver'] = 'mysql'
node.default['dovecot']['conf']['sql']['connect'] = [
  "host=#{node['postfixadmin']['database']['host']}",
  "dbname=#{node['postfixadmin']['database']['name']}",
  "user=#{node['postfixadmin']['database']['user']}",
  "password=#{node['postfixadmin']['database']['password']}",
]
case node['postfixadmin']['conf']['encrypt']
when 'md5crypt'
  node.default['dovecot']['conf']['sql']['default_pass_scheme'] = 'MD5-CRYPT'
when 'md5'
  node.default['dovecot']['conf']['sql']['default_pass_scheme'] = 'PLAIN-MD5'
when 'cleartext'
  node.default['dovecot']['conf']['sql']['default_pass_scheme'] = 'PLAIN'
else
  log("Unknown postfixadmin encrypt mode, #{node['postfixadmin']['conf']['encrypt']}, using PLAIN") { level :warn }
  node.default['dovecot']['conf']['sql']['default_pass_scheme'] = 'PLAIN'
end
node.default['dovecot']['conf']['sql']['password_query'] = [
  'SELECT username AS user, password',
  'FROM mailbox',
  'WHERE username = \'%u\' AND active = \'1\'',
]
node.default['dovecot']['conf']['sql']['user_query'] = [
  "SELECT username AS user, password, concat('#{node['postfix-dovecot']['vmail']['home']}/', maildir) AS home, concat('maildir:#{node['postfix-dovecot']['vmail']['home']}/', maildir) AS mail",
  'FROM mailbox',
  'WHERE username = \'%u\' AND active = \'1\'',
]

node.default['dovecot']['conf']['sql']['iterate_query'] = [
  'SELECT username AS user',
  'FROM mailbox WHERE active = \'1\'',
]

include_recipe 'dovecot'

# this should go after installing dovecot, sievec is required
execute 'sievec sieve_global_path' do
  command "sievec '#{node['dovecot']['plugins']['sieve']['sieve_global_path']}'"
  action :nothing
end
directory ::File.dirname(node['dovecot']['plugins']['sieve']['sieve_global_path']) do
  owner 'root'
  group 'root'
  mode '00755'
  recursive true
  not_if do
    ::File.exists?(::File.dirname(node['dovecot']['plugins']['sieve']['sieve_global_path'])) or
    not node['postfix-dovecot']['sieve']['enabled']
  end
end
template node['dovecot']['plugins']['sieve']['sieve_global_path'] do
  source 'default.sieve.erb'
  # TODO reinforcing this
  owner 'root'
  group 'root'
  mode '00644'
  only_if do node['postfix-dovecot']['sieve']['enabled'] end
  notifies :run, 'execute[sievec sieve_global_path]'
end

