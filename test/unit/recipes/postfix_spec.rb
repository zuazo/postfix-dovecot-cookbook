# encoding: UTF-8
#
# Author:: Xabier de Zuazo (<xabier@zuazo.org>)
# Copyright:: Copyright (c) 2014-2015 Onddo Labs, SL.
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

require_relative '../spec_helper'
require 'chef-vault'

describe 'postfix-dovecot::postfix' do
  let(:hostname) { 'my_hostname' }
  let(:chef_runner) { ChefSpec::SoloRunner.new }
  let(:chef_run) { chef_runner.converge(described_recipe) }
  let(:node) { chef_runner.node }
  chroot_files = %w(
    etc/resolv.conf
    etc/localtime
    etc/services
    etc/resolv.conf
    etc/hosts
    etc/nsswitch.conf
    etc/nss_mdns.config
  )
  before do
    node.set['postfix-dovecot']['hostname'] = hostname
    allow(::File).to receive(:exist?).and_call_original
    allow(::IO).to receive(:read).and_call_original
    chroot_files.each do |chroot_file|
      allow(::File).to receive(:exist?).with("/#{chroot_file}")
        .and_return(true)
      allow(::IO).to receive(:read).with("/#{chroot_file}")
        .and_return("content:#{chroot_file}")
    end
  end

  it 'removes sendmail package' do
    expect(chef_run).to remove_package('sendmail')
  end

  it 'includes postfix_mysql recipe by default' do
    expect(chef_run).to include_recipe('postfix-dovecot::postfix_mysql')
  end

  it 'creates tables directory' do
    expect(chef_run).to create_directory('/etc/postfix/tables')
      .with_recursive(true)
      .with_owner('root')
      .with_group('root')
      .with_mode(00755)
  end

  context 'with MySQL' do
    before do
      chef_runner.node.set['postfix-dovecot']['database']['type'] =
        'mysql'
    end

    it 'includes postfix_mysql recipe' do
      expect(chef_run).to include_recipe('postfix-dovecot::postfix_mysql')
    end
  end

  context 'with PostgreSQL' do
    before do
      chef_runner.node.set['postfix-dovecot']['database']['type'] =
        'postgresql'
    end

    it 'includes postfix_postgresql recipe' do
      expect(chef_run).to include_recipe('postfix-dovecot::postfix_postgresql')
    end
  end

  it 'generates SMTP SSL certificate' do
    expect(chef_run).to create_ssl_certificate('postfix')
  end

  it 'creates myorigin file' do
    expect(chef_run).to create_file('/etc/mailname')
      .with_content(hostname)
  end

  it 'includes postfix-full recipe' do
    expect(chef_run).to include_recipe('postfix-full')
  end

  it 'creates chroot etc directory' do
    expect(chef_run).to create_directory('/var/spool/postfix/etc')
      .with_user('root')
      .with_group('root')
      .with_mode('0755')
  end

  chroot_files.each do |chroot_file|
    it "creates chroot #{chroot_file} file" do
      expect(chef_run).to create_file("/var/spool/postfix/#{chroot_file}")
        .with_user('root')
        .with_group('root')
        .with_mode('0644')
    end
  end # each chroot_file

  it 'etc/resolv.conf creation notifies postfix restart' do
    resource = chef_run.file('/var/spool/postfix/etc/resolv.conf')
    expect(resource).to notify('service[postfix]').to(:restart)
  end

  context 'with RBLs' do
    before do
      node.set['postfix-dovecot']['rbls'] = %w(
        dnsbl.sorbs.net
        zen.spamhaus.org
        bl.spamcop.net
        cbl.abuseat.org
      )
    end

    it 'adds blacklists to the smtpd_recipient_restrictions' do
      chef_run
      expect(node['postfix']['main']['smtpd_recipient_restrictions'])
        .to match(/, reject_rbl_client zen\.spamhaus\.org,/)
    end
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
    let(:vault_item) { 'ses' }
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
      node.set['postfix-dovecot']['ses']['item'] = vault_item
      allow(Chef::DataBag).to receive(:load)
        .and_return("#{vault_item}_keys" => {})
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
        sasl_passwd_content =
          "email-smtp.us-east-1.amazonaws.com:587 #{credentials}"
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
        sasl_passwd_content =
          "email-smtp.us-east-1.amazonaws.com:587 #{credentials}"
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
