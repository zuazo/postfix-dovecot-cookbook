# encoding: UTF-8
#
# Cookbook Name:: postfix-dovecot_test
# Recipe:: default
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

if node['postfix-dovecot']['database']['type'] == 'postgresql'
  include_recipe 'postfix-dovecot_test::postgresql_memory'
end

node.default['postfix-dovecot']['spamc']['enabled'] = true

node.default['postgresql']['password']['postgres'] = 'vagrant_postgres'
node.default['postfixadmin']['mysql']['server_root_password'] = 'vagrant_root'

node.default['postfixadmin']['database']['password'] = 'postfix_pass'
node.default['postfixadmin']['setup_password'] = '4dm1n'
node.default['postfixadmin']['setup_password_salt'] = 'salt'

include_recipe 'postfix-dovecot'

postfixadmin_admin 'admin@foobar.com' do
  password 'p@ssw0rd1'
end

postfixadmin_domain 'foobar.com' do
  login_username 'admin@foobar.com'
  login_password 'p@ssw0rd1'
end

postfixadmin_mailbox 'postmaster@foobar.com' do
  password 'p0stm@st3r1'
  login_username 'admin@foobar.com'
  login_password 'p@ssw0rd1'
end

package 'lsof' # required for integration tests
package 'wget' # required for integration tests
