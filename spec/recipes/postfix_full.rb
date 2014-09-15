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

describe 'postfix-dovecot::postfix_full' do
  let(:hostname) { 'my_hostname' }
  let(:chef_runner) do
    ChefSpec::Runner.new do |node|
      node.set['postfix-dovecot']['hostname'] = hostname
    end
  end
  let(:chef_run) { chef_runner.converge(described_recipe) }

  it 'should remove sendmail package' do
    expect(chef_run).to remove_package('sendmail')
  end

  context 'on CentOS' do
    before do
      chef_runner.node.automatic['platform'] = 'centos'
    end

    it 'should not install postfix-mysql packaged' do
      expect(chef_run).to_not install_package('postfix-mysql')
    end
  end

  context 'on Ubuntu' do
    before do
      chef_runner.node.automatic['platform'] = 'ubuntu'
    end

    it 'should install postfix-mysql packaged' do
      expect(chef_run).to install_package('postfix-mysql')
    end
  end

  it 'should generate SMTP SSL certificate' do
    expect(chef_run).to create_ssl_certificate('postfix')
  end

  it 'should create myorigin file' do
    expect(chef_run).to create_file('/etc/mailname')
      .with_content(hostname)
  end

  it 'should include postfix-full recipe' do
    expect(chef_run).to include_recipe('postfix-full')
  end

end
