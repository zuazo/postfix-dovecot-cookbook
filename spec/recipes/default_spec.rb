# encoding: UTF-8
#
# Author:: Xabier de Zuazo (<xabier@onddo.com>)
# Copyright:: Copyright (c) 2014 Onddo Labs, SL. (www.onddo.com)
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

require 'spec_helper'

describe 'postfix-dovecot::default' do
  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }
  before do
    stub_command('/usr/sbin/apache2 -t').and_return(true)
  end

  %w(
    postfix-dovecot::vmail
    postfix-dovecot::spam
    postfix-dovecot::postfix_full
    postfix-dovecot::postfixadmin
    postfix-dovecot::dovecot
  ).each do |recipe|
    it "should include #{recipe} recipe" do
      expect(chef_run).to include_recipe(recipe)
    end
  end

end
