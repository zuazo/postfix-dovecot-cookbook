# encoding: UTF-8
#
# Cookbook Name:: postfix-dovecot
# Recipe:: spam
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

if node['postfix-dovecot']['spamc']['enabled']
  if node['postfix-dovecot']['spamc']['recipe'] == 'onddo-spamassassin'
    node.default['spamassassin']['spamd']['enabled'] = true
    node.default['spamassassin']['spamd']['options'] = %w(
      --create-prefs
      --max-children 3
      --helper-home-dir
    )
    # local.cf
    node.default['spamassassin']['conf']['rewrite_header'] = [
      Subject: '[SPAM]'
    ]
    node.default['spamassassin']['conf']['report_safe'] = false
    node.default['spamassassin']['conf']['lock_method'] = 'flock'
    node.default['postfix-dovecot']['spamc']['path'] =
      node['spamassassin']['spamc']['path']

    include_recipe node['postfix-dovecot']['spamc']['recipe']
  else
    node.default['postfix-dovecot']['spamc']['path'] = '/usr/bin/spamc'
  end
end
