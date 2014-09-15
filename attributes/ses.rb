# encoding: UTF-8

default['postfix-dovecot']['ses']['enabled'] = false
default['postfix-dovecot']['ses']['username'] = 'USERNAME'
default['postfix-dovecot']['ses']['password'] = 'PASSWORD'
default['postfix-dovecot']['ses']['servers'] = %w(
  email-smtp.us-east-1.amazonaws.com:25
  ses-smtp-prod-335357831.us-east-1.elb.amazonaws.com:25
)
