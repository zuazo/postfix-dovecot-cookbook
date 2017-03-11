# encoding: UTF-8
#
# Cookbook Name:: postfix-dovecot
# Recipe:: vmail
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

user node['postfix-dovecot']['vmail']['user'] do
  comment node['postfix-dovecot']['vmail']['user'].capitalize
  home node['postfix-dovecot']['vmail']['home']
  shell '/bin/false'
  uid node['postfix-dovecot']['vmail']['uid']
  manage_home true
  system true
end

group node['postfix-dovecot']['vmail']['group'] do
  gid node['postfix-dovecot']['vmail']['gid']
  members [node['postfix-dovecot']['vmail']['user']]
  system true
  append true
end
