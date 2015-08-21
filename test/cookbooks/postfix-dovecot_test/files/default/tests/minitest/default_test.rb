# encoding: UTF-8
#
# Author:: Xabier de Zuazo (<xabier@zuazo.org>)
# Copyright:: Copyright (c) 2013-2015 Onddo Labs, SL.
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

require File.expand_path('../support/helpers', __FILE__)

describe 'postfix-dovecot::default' do
  include Helpers::PostfixDovecotTest

  describe 'postfix' do
    it 'postfix should be running' do
      service('postfix').must_be_running
    end

    it 'should be able to send mails through SES' do
      skip unless node['postfix-dovecot']['ses']['enabled']
      send_test_mail(
        node['postfix-dovecot']['ses']['email'], 'blackhole@zuazo.org'
      )
    end
  end

  describe 'dovecot' do
    it 'dovecot should be running' do
      service('dovecot').must_be_running
    end
  end
end
