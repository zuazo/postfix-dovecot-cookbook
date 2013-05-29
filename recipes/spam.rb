#
# Cookbook Name:: postfix-dovecot
# Recipe:: spam
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

if node['postfix-dovecot']['spamc']['enabled']
  if node['postfix-dovecot']['spamc']['recipe'] == 'onddo-spamassassin'
    node.default['onddo-spamassassin']['spamd']['enabled'] = true
    node.default['onddo-spamassassin']['spamd']['options'] = [
      '--create-prefs',
      '--max-children 3',
      '--helper-home-dir',
    ]
    # local.cf
    node.default['onddo-spamassassin']['conf']['rewrite_header'] = [ 'Subject' => '[SPAM]' ]
    node.default['onddo-spamassassin']['conf']['report_safe'] = false
    node.default['onddo-spamassassin']['conf']['lock_method'] = 'flock'
    node.default['postfix-dovecot']['spamc']['path'] = node['onddo-spamassassin']['spamc']['path']

    include_recipe node['postfix-dovecot']['spamc']['recipe']
  else
    node.default['postfix-dovecot']['spamc']['path'] = '/usr/bin/spamc'
  end
end

