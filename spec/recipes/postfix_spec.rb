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

describe 'postfix-dovecot::postfix' do
  let(:hostname) { 'my_hostname' }
  let(:chef_runner) { ChefSpec::SoloRunner.new }
  let(:chef_run) { chef_runner.converge(described_recipe) }
  let(:node) { chef_runner.node }
  before do
    node.set['postfix-dovecot']['hostname'] = hostname
    allow(::File).to receive(:exist?).and_return(false)
    allow(::File).to receive(:exist?).with('/etc/resolv.conf')
      .and_return(true)
    allow(::IO).to receive(:read?).with('/etc/resolv.conf')
      .and_return('OK')
  end

  it 'should remove sendmail package' do
    expect(chef_run).to remove_package('sendmail')
  end

  it 'should include postfix_mysql recipe by default' do
    expect(chef_run).to include_recipe('postfix-dovecot::postfix_mysql')
  end

  context 'with MySQL' do
    before do
      chef_runner.node.set['postfix-dovecot']['database']['type'] =
        'mysql'
    end

    it 'should include postfix_mysql recipe' do
      expect(chef_run).to include_recipe('postfix-dovecot::postfix_mysql')
    end
  end

  context 'with PostgreSQL' do
    before do
      chef_runner.node.set['postfix-dovecot']['database']['type'] =
        'postgresql'
    end

    it 'should include postfix_postgresql recipe' do
      expect(chef_run).to include_recipe('postfix-dovecot::postfix_postgresql')
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

  it 'should create chroot etc directory' do
    expect(chef_run).to create_directory('/var/spool/postfix/etc')
      .with_user('root')
      .with_group('root')
      .with_mode('0755')
  end

  it 'should create chroot etc/resolv.conf file' do
    expect(chef_run).to create_file('/var/spool/postfix/etc/resolv.conf')
      .with_user('root')
      .with_group('root')
      .with_mode('0644')
  end

  it 'etc/resolv.conf creation should notify postfix restart' do
    resource = chef_run.file('/var/spool/postfix/etc/resolv.conf')
    expect(resource).to notify('service[postfix]').to(:restart)
  end

  context 'with SES enabled' do
    let(:attr_username) { 'AMAZON_SES_USERNAME_ATTR' }
    let(:attr_password) { 'AMAZON_SES_PASSWORD_ATTR' }
    let(:attr_credentials) do
      {
        'username' => attr_username,
        'password' => attr_password
      }
    end
    let(:vault_username) { 'AMAZON_SES_USERNAME_VAULT' }
    let(:vault_password) { 'AMAZON_SES_PASSWORD_VAULT' }
    let(:vault_credentials) do
      {
        'username' => vault_username,
        'password' => vault_password
      }
    end
    before do
      node.set['postfix-dovecot']['ses']['enabled'] = true
      node.set['postfix-dovecot']['ses']['username'] = attr_username
      node.set['postfix-dovecot']['ses']['password'] = attr_password
      allow(ChefVault::Item).to receive(:load).and_return(vault_credentials)
    end

    it 'does not use chef-vault by default' do
      chef_run
      expect(node['postfix-dovecot']['ses']['source']).to eq('attributes')
    end

    context 'with Chef Vault' do
      before do
        node.set['postfix-dovecot']['ses']['source'] = 'chef-vault'
      end

      it 'includes chef-vault recipe' do
        expect(chef_run).to include_recipe('chef-vault')
      end

      it 'reads chef vault' do
        expect(ChefVault::Item).to receive(:load)
          .with('amazon', 'ses').once.and_return(vault_credentials)
        chef_run
      end

      it 'creates postmap sasl_passwd resource' do
        resource = chef_run.execute('postmap /etc/postfix/tables/sasl_passwd')
        expect(resource).to do_nothing
      end

      it 'creates sasl_passwd file' do
        expect(chef_run).to create_file('/etc/postfix/tables/sasl_passwd')
          .with_owner('root')
          .with_group(0)
          .with_mode('00640')
      end

      it 'sets vault credentials inside sasl_passwd file' do
        credentials = "#{vault_username}:#{vault_password}"
        sasl_passwd_content = [
          "email-smtp.us-east-1.amazonaws.com:25 #{credentials}",
          'ses-smtp-prod-335357831.us-east-1.elb.amazonaws.com:25'\
          " #{credentials}"

        ].join("\n")
        expect(chef_run).to create_file('/etc/postfix/tables/sasl_passwd')
          .with_content(sasl_passwd_content + "\n")
      end

      context 'sasl_passwd file' do
        let(:resource) { chef_run.file('/etc/postfix/tables/sasl_passwd') }

        it 'notifies postmap sasl_passwd' do
          expect(resource)
            .to notify('execute[postmap /etc/postfix/tables/sasl_passwd]')
            .to(:run).delayed
        end
      end # context sasl_passwd file
    end # context with Chef Vault

    context 'without Chef Vault' do
      before do
        node.set['postfix-dovecot']['ses']['source'] = 'attributes'
      end

      it 'does not include chef-vault recipe' do
        expect(chef_run).to_not include_recipe('chef-vault')
      end

      it 'does not read the chef vault' do
        expect(ChefVault::Item).to_not receive(:load)
          .with('api_dev_kinton_eu', 'ses')
        chef_run
      end

      it 'creates postmap sasl_passwd resource' do
        resource = chef_run.execute('postmap /etc/postfix/tables/sasl_passwd')
        expect(resource).to do_nothing
      end

      it 'creates sasl_passwd file' do
        expect(chef_run).to create_file('/etc/postfix/tables/sasl_passwd')
          .with_owner('root')
          .with_group(0)
          .with_mode('00640')
      end

      it 'sets vault credentials inside sasl_passwd file' do
        credentials = "#{attr_username}:#{attr_password}"
        sasl_passwd_content = [
          "email-smtp.us-east-1.amazonaws.com:25 #{credentials}",
          'ses-smtp-prod-335357831.us-east-1.elb.amazonaws.com:25'\
          " #{credentials}"

        ].join("\n")
        expect(chef_run).to create_file('/etc/postfix/tables/sasl_passwd')
          .with_content(sasl_passwd_content + "\n")
      end

      context 'sasl_passwd file' do
        let(:resource) { chef_run.file('/etc/postfix/tables/sasl_passwd') }

        it 'notifies postmap sasl_passwd' do
          expect(resource)
            .to notify('execute[postmap /etc/postfix/tables/sasl_passwd]')
            .to(:run).delayed
        end
      end # context sasl_passwd file
    end # context without Chef Vault
  end # context with SES enabled

end
