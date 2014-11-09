# encoding: UTF-8
#
# Cookbook Name:: postfix-dovecot
# Recipe:: postfix
# Author:: Xabier de Zuazo (<xabier@onddo.com>)
# Copyright:: Copyright (c) 2013 Onddo Labs, SL. (www.onddo.com)
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

package 'sendmail' do
  action :remove
end

db_type =
  case node['postfix-dovecot']['database']['type']
  when 'mysql'
    include_recipe 'postfix-dovecot::postfix_mysql'
    'mysql'
  when 'postgresql'
    include_recipe 'postfix-dovecot::postfix_postgresql'
    'pgsql'
  else
    nil
  end

tables_path = "#{node['postfix']['base_dir']}/tables"
# check if we can get the tables path from the postfixadmin cookbook
if node['postfixadmin'] && node['postfixadmin']['map_files'] &&
   node['postfixadmin']['map_files']['path']
  tables_path = node['postfixadmin']['map_files']['path']
end

#
# master.cf
#

# submission inet n       -       -       -       -       smtpd
#   -o syslog_name=postfix/submission
#   -o smtpd_tls_security_level=encrypt
#   -o smtpd_sasl_auth_enable=yes
#   -o smtpd_client_restrictions=permit_sasl_authenticated,reject
#   -o milter_macro_daemon_name=ORIGINATING
node.default['postfix']['master']['inet:submission']['command'] = 'smtpd'
node.default['postfix']['master']['inet:submission']['private'] = false
node.default['postfix']['master']['inet:submission']['args'] =
  [
    '-o syslog_name=postfix/submission',
    '-o smtpd_tls_security_level=encrypt',
    '-o smtpd_sasl_auth_enable=yes',
    '-o smtpd_client_restrictions=permit_sasl_authenticated,reject',
    '-o milter_macro_daemon_name=ORIGINATING'
  ]

# smtps     inet  n       -       -       -       -       smtpd
#   -o syslog_name=postfix/smtps
#   -o smtpd_tls_wrappermode=yes
#   -o smtpd_sasl_auth_enable=yes
#   -o smtpd_client_restrictions=permit_sasl_authenticated,reject
#   -o milter_macro_daemon_name=ORIGINATING
node.default['postfix']['master']['inet:smtps']['command'] = 'smtpd'
node.default['postfix']['master']['inet:smtps']['private'] = false
node.default['postfix']['master']['inet:smtps']['args'] =
  [
    '-o syslog_name=postfix/smtps',
    '-o smtpd_tls_wrappermode=yes',
    '-o smtpd_sasl_auth_enable=yes',
    '-o smtpd_client_restrictions=permit_sasl_authenticated,reject',
    '-o milter_macro_daemon_name=ORIGINATING'
  ]

# dovecot   unix  -       n       n       -       -       pipe
#   flags=DRhu user=vmail:vmail argv=/usr/bin/spamc -e /usr/lib/dovecot/deliver
#     -f {sender} -d ${recipient}
dovecot_argv = [
  "#{node['dovecot']['lib_path']}/deliver",
  '-f {sender}',
  '-d ${recipient}'
]
if node['postfix-dovecot']['spamc']['enabled']
  dovecot_argv.unshift("#{node.default['postfix-dovecot']['spamc']['path']} -e")
end
node.default['postfix']['master']['dovecot']['command'] = 'pipe'
node.default['postfix']['master']['dovecot']['unpriv'] = false
node.default['postfix']['master']['dovecot']['chroot'] = false
node.default['postfix']['master']['dovecot']['args'] =
  [
    "flags=DRhu user=#{node['postfix-dovecot']['vmail']['user']}:"\
    "#{node['postfix-dovecot']['vmail']['group']} "\
    "argv=#{dovecot_argv.join(' ')}"
  ]

#
# main.cf
#

node.default['postfix']['main']['mynetworks'] =
  '127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128'
node.default['postfix']['main']['recipient_delimiter'] = '+'
node.default['postfix']['tables']['aliases']['_type'] = 'hash'
node.default['postfix']['tables']['aliases']['_set'] = 'alias_maps'
node.default['postfix']['tables']['aliases']['_add'] = 'alias_database'
node.default['postfix']['tables']['aliases']['_file'] = '/etc/aliases'
node.default['postfix']['tables']['aliases']['_cmd'] = 'postalias'
node.default['postfix']['tables']['aliases']['postmaster:'] = 'root'

node.default['postfix']['main']['smtpd_banner'] = '$myhostname ESMTP $mail_name'
node.default['postfix']['main']['biff'] = false
node.default['postfix']['main']['append_dot_mydomain'] = 'no'
node.default['postfix']['main']['readme_directory'] = false
node.default['postfix']['main']['smtpd_helo_required'] = true

node.default['postfix']['main']['smtpd_helo_restrictions'] = %w(
  permit_mynetworks
  reject_invalid_hostname
  permit
)
node.default['postfix']['main']['smtpd_recipient_restrictions'] = %w(
  permit_mynetworks
  permit_sasl_authenticated
  reject_invalid_hostname
  reject_non_fqdn_hostname
  reject_non_fqdn_recipient
  reject_unknown_recipient_domain
  reject_unauth_pipelining
  reject_unauth_destination
  permit
)

# TLS parameters
node.default_unless['postfix-dovecot']['common_name'] =
  node['postfix-dovecot']['hostname']
cert = ssl_certificate 'postfix' do
  namespace node['postfix-dovecot']
  notifies :restart, 'service[postfix]'
end
node.default['postfix']['main']['smtpd_tls_cert_file'] = cert.cert_path
node.default['postfix']['main']['smtpd_tls_key_file'] = cert.key_path
node.default['postfix']['main']['smtpd_use_tls'] = true
node.default['postfix']['main']['smtpd_tls_session_cache_database'] =
  'btree:${data_directory}/smtpd_scache'
node.default['postfix']['main']['smtp_tls_session_cache_database'] =
  'btree:${data_directory}/smtp_scache'

# SASL authentication
node.default['postfix']['main']['smtpd_sasl_auth_enable'] = true
node.default['postfix']['main']['smtpd_sasl_path'] = 'private/auth'
node.default['postfix']['main']['smtpd_sasl_type'] = 'dovecot'
node.default['postfix']['main']['smtpd_tls_auth_only'] = true

# Virtual delivery
node.default['postfix']['main']['virtual_mailbox_domains'] = [
  "proxy:#{db_type}:#{tables_path}/db_virtual_domains_maps.cf"
]
node.default['postfix']['main']['virtual_alias_maps'] = [
  "proxy:#{db_type}:#{tables_path}/db_virtual_alias_maps.cf",
  "proxy:#{db_type}:#{tables_path}/db_virtual_alias_domain_maps.cf",
  "proxy:#{db_type}:#{tables_path}/db_virtual_alias_domain_catchall_maps.cf"
]
node.default['postfix']['main']['virtual_mailbox_maps'] = [
  "proxy:#{db_type}:#{tables_path}/db_virtual_mailbox_maps.cf",
  "proxy:#{db_type}:#{tables_path}/db_virtual_alias_domain_mailbox_maps.cf"
]
node.default['postfix']['main']['virtual_mailbox_base'] =
  node['postfix-dovecot']['vmail']['home']
node.default['postfix']['main']['virtual_uid_maps'] =
  "static:#{node['postfix-dovecot']['vmail']['uid']}"
node.default['postfix']['main']['virtual_gid_maps'] =
  "static:#{node['postfix-dovecot']['vmail']['gid']}"
node.default['postfix']['main']['virtual_transport'] = 'dovecot'
node.default['postfix']['main']['dovecot_destination_recipient_limit'] = 1

# Amazon SES
if node['postfix-dovecot']['ses']['enabled']
  ses_credentials_hs =
    case node['postfix-dovecot']['ses']['source']
    when 'chef-vault', 'vault'
      ses_vault = node['postfix-dovecot']['ses']['vault']
      include_recipe 'chef-vault'
      chef_vault_item(ses_vault, node['postfix-dovecot']['ses']['item'])
    else
      node['postfix-dovecot']['ses']
    end
  ses_credentials = [
    ses_credentials_hs['username'],
    ses_credentials_hs['password']
  ].join(':')

  node.default['postfix']['main']['relayhost'] =
    node['postfix-dovecot']['ses']['servers'][0]
  node.default['postfix']['main']['smtp_sasl_auth_enable'] = true
  node.default['postfix']['main']['smtp_sasl_security_options'] = 'noanonymous'
  node.default['postfix']['main']['smtp_use_tls'] = true
  node.default['postfix']['main']['smtp_tls_security_level'] = 'encrypt'
  node.default['postfix']['main']['smtp_tls_note_starttls_offer'] = true

  node.default['postfix']['main']['smtp_sasl_password_maps'] =
    'hash:/etc/postfix/tables/sasl_passwd'
  sasl_passwd_content =
    node['postfix-dovecot']['ses']['servers'].reduce('') do |r, server|
      r + "#{server} #{ses_credentials}\n"
    end

  execute 'postmap /etc/postfix/tables/sasl_passwd' do
    user 'root'
    group 0
    action :nothing
  end

  file '/etc/postfix/tables/sasl_passwd' do
    owner 'root'
    group 0
    mode '00640'
    content sasl_passwd_content
    notifies :run, 'execute[postmap /etc/postfix/tables/sasl_passwd]'
  end

  case node['platform']
  when 'redhat', 'centos', 'scientific', 'fedora', 'suse', 'amazon' then
    node.default['postfix']['main']['smtp_tls_CAfile'] =
      '/etc/ssl/certs/ca-bundle.crt'
  when 'debian', 'ubuntu' then
    node.default['postfix']['main']['smtp_tls_CAfile'] =
      '/etc/ssl/certs/ca-certificates.crt'
  else
    Chef::Log.warn("Unsupported platform: #{node['platform']}, trying to "\
      'guess CA certificates file location'
    )
    node.default['postfix']['main']['smtp_tls_CAfile'] =
      '/etc/ssl/certs/ca-certificates.crt'
  end
end

node['postfix']['main'].each do |key, value|
  node.default['postfix']['main'][key] = value.join(', ') if value.is_a?(Array)
end

file node['postfix']['main']['myorigin'] do
  content node['postfix-dovecot']['hostname']
end

include_recipe 'postfix-full'

# Create some chroot dir/files, until postfix-full >= 0.1.3 is released:
# https://github.com/mswart/chef-postfix-full/pull/8

postfix_chroot =
  node['postfix']['main']['queue_directory'] || '/var/spool/postfix'
chroot_files = %w(
  etc/resolv.conf
  etc/localtime
  etc/services
  etc/resolv.conf
  etc/hosts
  etc/nsswitch.conf
  etc/nss_mdns.config
)

chroot_files.each do |path|
  dir_path = ::File.dirname(path)
  chroot_dir_path = ::File.join(postfix_chroot, dir_path)

  directory chroot_dir_path do
    owner 'root'
    group 'root'
    mode '0755'
    recursive true
    only_if do
      dir_path.length > 0 &&
        !::File.exist?(chroot_dir_path)
    end
  end

  full_path = ::File.join('', path)
  file_exist = ::File.exist?(full_path)
  file_content = file_exist ? IO.read(full_path) : nil # avoid ENOENT error

  file ::File.join(postfix_chroot, path) do
    owner 'root'
    group 'root'
    mode '0644'
    content file_content
    only_if { file_exist }
    notifies :restart, 'service[postfix]'
  end
end
