#
# Cookbook Name:: postfix-dovecot_test
# Recipe:: default
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

