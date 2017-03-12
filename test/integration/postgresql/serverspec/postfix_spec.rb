# encoding: UTF-8
#
# Author:: Xabier de Zuazo (<xabier@zuazo.org>)
# Copyright:: Copyright (c) 2014 Onddo Labs, SL.
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
require 'net/smtp'
require_relative 'mail_helpers'

describe 'Postfix' do
  describe command('/usr/sbin/postconf') do
    its(:exit_status) { should eq 0 }
    its(:stderr) { should eq '' }
  end

  describe process('master') do
    it { should be_running }
  end

  # smtp
  describe port(25) do
    it { should be_listening.with('tcp') }
  end

  # ssmtp
  describe port(465) do
    it { should be_listening.with('tcp') }
  end

  # submission
  describe port(587) do
    it { should be_listening.with('tcp') }
  end

  it 'connects to smtp SSL' do
    expect(
      command('echo | openssl s_client -connect 127.0.0.1:465')
        .exit_status
    ).to eq 0
  end

  it 'connects to smtp with starttls' do
    expect(
      command('echo | openssl s_client -starttls smtp -connect 127.0.0.1:smtp')
        .exit_status
    ).to eq 0
  end

  it 'is able to login using submission (plain)' do
    smtp = Net::SMTP.new 'localhost', 587
    ctx = OpenSSL::SSL::SSLContext.new
    ctx.verify_mode = OpenSSL::SSL::VERIFY_NONE
    smtp.enable_starttls(ctx)
    smtp.start(
      'onddo.com', 'postmaster@foobar.com', 'p0stm@st3r1', :plain
    ) { |_smtp| puts 'OK' }
  end

  describe 'when an email is sent through smtp' do
    fingerprint = "G27XB6yIyYyM99Tv8UXW#{Time.new.to_i}"
    let(:maildir) { '/var/vmail/foobar.com/postmaster' }
    before(:context) { send_email(fingerprint) }

    it 'is able to receive it', retry: 30, retry_wait: 1 do
      expect(all_file_contents("#{maildir}/new/*")).to include fingerprint
    end
  end

  family = os[:family].downcase
  key_dir, cert_dir =
    if %w(debian ubuntu).include?(family)
      %w(/etc/ssl/private /etc/ssl/certs)
    elsif %w(redhat centos fedora scientific amazon).include?(family)
      %w(/etc/pki/tls/private /etc/pki/tls/certs)
    else
      %w(/etc /etc)
    end

  describe file("#{cert_dir}/postfix.pem") do
    it { should be_file }
    it { should be_mode 644 }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
  end

  describe file("#{key_dir}/postfix.key") do
    it { should be_file }
    it { should be_mode 600 }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
  end

  describe file('/etc/mailname') do
    it { should be_file }
    it { should be_mode 644 }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
  end

  describe file('/var/spool/postfix/etc') do
    it { should be_directory }
    it { should be_mode 755 }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
  end

  %w(
    etc/resolv.conf
    etc/localtime
    etc/services
    etc/hosts
    etc/nsswitch.conf
    etc/nss_mdns.config
  ).each do |chroot_file|
    describe file("/var/spool/postfix/#{chroot_file}"),
             if: ::File.exist?("/#{chroot_file}") do
      it { should be_file }
      it { should be_mode 644 }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
    end
  end
end
