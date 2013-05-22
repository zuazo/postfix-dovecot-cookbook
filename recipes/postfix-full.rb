#
# Cookbook Name:: postfix-dovecot
# Recipe:: postfix-full
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

#submission inet n       -       -       -       -       smtpd
#  -o syslog_name=postfix/submission
#  -o smtpd_tls_security_level=encrypt
#  -o smtpd_sasl_auth_enable=yes
#  -o smtpd_client_restrictions=permit_sasl_authenticated,reject
#  -o milter_macro_daemon_name=ORIGINATING
node.default['postfix']['master']['inet:submission'] = {
  'command' => 'smtpd',
  'private' => false,
  'args' => [
    '-o syslog_name=postfix/submission',
    '-o smtpd_tls_security_level=encrypt',
    '-o smtpd_sasl_auth_enable=yes',
    '-o smtpd_client_restrictions=permit_sasl_authenticated,reject',
    '-o milter_macro_daemon_name=ORIGINATING'
  ],
}

#smtps     inet  n       -       -       -       -       smtpd
#  -o syslog_name=postfix/smtps
#  -o smtpd_tls_wrappermode=yes
#  -o smtpd_sasl_auth_enable=yes
#  -o smtpd_client_restrictions=permit_sasl_authenticated,reject
#  -o milter_macro_daemon_name=ORIGINATING
node.default['postfix']['master']['inet:smtps'] = { 
  'command' => 'smtpd',
  'private' => false,
  'args' => [
    '-o syslog_name=postfix/smtps',
    '-o smtpd_tls_wrappermode=yes',
    '-o smtpd_sasl_auth_enable=yes',
    '-o smtpd_client_restrictions=permit_sasl_authenticated,reject',
    '-o milter_macro_daemon_name=ORIGINATING'
  ],  
}

#dovecot   unix  -       n       n       -       -       pipe
#  flags=DRhu user=vmail:vmail argv=/usr/bin/spamc -e /usr/lib/dovecot/deliver -f {sender} -d ${recipient}
node.default['postfix']['master']['dovecot'] = { 
  'command' => 'pipe',
  'unpriv' => false,
  'chroot' => false,
  'args' => [
    'flags=DRhu user=vmail:vmail argv=/usr/bin/spamc -e /usr/lib/dovecot/deliver -f {sender} -d ${recipient}',
  ],  
}

include_recipe 'postfix-full::default'

