# encoding: UTF-8

default['postfix-dovecot']['postmaster_address'] = 'postmaster@foo.bar'
default['postfix-dovecot']['hostname'] = node['fqdn'] || 'postfix-dovecot.local'
