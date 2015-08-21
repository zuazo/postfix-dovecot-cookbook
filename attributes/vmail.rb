# encoding: UTF-8
#
# Cookbook Name:: postfix-dovecot
# Attributes:: vmail
# Author:: Xabier de Zuazo (<xabier@zuazo.org>)
# Copyright:: Copyright (c) 2013 Onddo Labs, SL.
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

default['postfix-dovecot']['spamc']['recipe'] = 'onddo-spamassassin'
default['postfix-dovecot']['spamc']['enabled'] = false

default['postfix-dovecot']['vmail']['user'] = 'vmail'
default['postfix-dovecot']['vmail']['group'] =
  node['postfix-dovecot']['vmail']['user']
default['postfix-dovecot']['vmail']['uid'] = 5000
default['postfix-dovecot']['vmail']['gid'] =
  node['postfix-dovecot']['vmail']['uid']
default['postfix-dovecot']['vmail']['home'] = '/var/vmail'
