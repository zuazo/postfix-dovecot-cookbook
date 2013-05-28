
default['postfix-dovecot']['vmail']['user'] = 'vmail'
default['postfix-dovecot']['vmail']['group'] = node['postfix-dovecot']['vmail']['user']
default['postfix-dovecot']['vmail']['uid'] = 5000
default['postfix-dovecot']['vmail']['gid'] = node['postfix-dovecot']['vmail']['uid']
default['postfix-dovecot']['vmail']['home'] = '/var/vmail'

