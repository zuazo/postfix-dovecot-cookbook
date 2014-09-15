# encoding: UTF-8

default['postfix-dovecot']['sieve']['enabled'] = true
default['postfix-dovecot']['sieve']['global_path'] = ::File.join(
  node['dovecot']['conf_path'], 'sieve', 'default.sieve'
)
