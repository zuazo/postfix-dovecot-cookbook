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

describe 'postfix-dovecot::postfix_postgresql' do
  let(:chef_runner) { ChefSpec::SoloRunner.new }
  let(:chef_run) { chef_runner.converge(described_recipe) }
  let(:node) { chef_runner.node }
  let(:buildroot) { '/root/rpmbuild' }

  context 'with RPM platforms' do
    let(:yd_shell_out) { instance_double('Mixlib::ShellOut') }
    let(:srpm) { 'foobar-1.0_19.src.tar.gz' }
    let(:rpm) { "foobar-1.0_19.centos.#{node['kernel']['machine']}.tar.gz" }
    before do
      node.automatic['platform'] = 'centos'
      allow(Mixlib::ShellOut).to receive(:new)
        .with('yumdownloader --source --urls postfix').and_return(yd_shell_out)
      allow(yd_shell_out).to receive(:run_command).and_return(yd_shell_out)
      allow(yd_shell_out).to receive(:error!)
      allow(yd_shell_out).to receive(:stdout)
        .and_return("http://example.org/#{srpm}")
      stub_command('postconf -m | grep -qFw pgsql').and_return(false)
      stub_command('rpm -q postfix').and_return(false)
    end

    it 'does not install postfix package' do
      expect(chef_run).to_not install_package('postfix')
    end

    it 'does not install postfix-pgsql package' do
      expect(chef_run).to_not install_package('postfix-pgsql')
    end

    it 'installs yum-utils package at compile time' do
      expect(chef_run).to install_package('yum-utils').at_compile_time
    end

    it 'searches the source using yumdownloader' do
      expect(Mixlib::ShellOut).to receive(:new).once
        .with('yumdownloader --source --urls postfix').and_return(yd_shell_out)
      chef_run
    end

    it 'checks yumdownloader for errors' do
      expect(yd_shell_out).to receive(:error!)
      chef_run
    end

    it 'executes yumdownloader postfix' do
      expect(chef_run).to run_execute('yumdownloader postfix')
        .with_command(
          "yumdownloader --source --destdir=#{buildroot}/SRPMS postfix"
        )
        .with_creates("#{buildroot}/SRPMS/#{srpm}")
    end

    it 'removes postfix if no pgsql support' do
      stub_command('postconf -m | grep -qFw pgsql').and_return(false)
      expect(chef_run).to remove_yum_package('postfix (without postgresql)')
        .with_package_name('postfix')
    end

    {
      'foobar-1.0_19.centos.x86_64.tar.gz' =>
        [/\.src\./, '.centos.x86_64.'],
      'foobar-1.0.x86_64.tar.gz' =>
        [/_[0-9]+\.src\./, '.x86_64.'],
      'foobar-1.0_19.x86_64.tar.gz' =>
        [/\.src\./, '.x86_64.']
    }.each do |rpm, rpm_regexp|
      it "returns #{rpm} using #{rpm_regexp} RPM regexp" do
        node.set['postfix-dovecot']['postfix']['srpm']['rpm_regexp'] =
          rpm_regexp
        expect(chef_run).to run_execute('install postfix from SRPM')
          .with_command("rpm -i '#{buildroot}/RPMS/x86_64/#{rpm}'")
      end
    end

    it 'does not remove postfix if pgsql support' do
      stub_command('postconf -m | grep -qFw pgsql').and_return(true)
      expect(chef_run).to_not remove_yum_package('postfix (without postgresql)')
        .with_package_name('postfix')
    end

    it 'compiles postfix SRPM' do
      expect(chef_run).to run_execute('compile postfix from SRPM')
        .with_environment('HOME' => '/root')
        .with_creates("#{buildroot}/RPMS/#{node['kernel']['machine']}/#{rpm}")
    end

    it 'installs postfix SRPM if not installed' do
      stub_command('rpm -q postfix').and_return(false)
      expect(chef_run).to run_execute('install postfix from SRPM')
        .with_command(
          "rpm -i '#{buildroot}/RPMS/#{node['kernel']['machine']}/#{rpm}'"
        )
    end

    it 'does not install postfix SRPM if installed' do
      stub_command('rpm -q postfix').and_return(true)
      expect(chef_run).to_not run_execute('install postfix from SRPM')
    end

    context 'with CentOS 7' do
      let(:rpm) do
        "postfix-2.10.1-6.el7.centos.#{node['kernel']['machine']}.rpm"
      end
      let(:srpm) { 'postfix-2.10.1-6.el7.src.rpm' }
      let(:rpmbuild_args) { '--with=pgsql' }
      before do
        node.automatic['platform'] = 'centos'
        node.automatic['platform_version'] = '7.0'
      end

      %w(
        postgresql-devel rpm-build zlib-devel openldap-devel libdb-devel
        cyrus-sasl-devel pcre-devel openssl-devel perl-Date-Calc gcc
        mariadb-devel pkgconfig ed tar systemd-sysv
      ).each do |pkg|
        it "installs #{pkg} package" do
          expect(chef_run).to install_package(pkg)
        end
      end

      it 'installs the correct RPM' do
        expect(chef_run).to run_execute('install postfix from SRPM')
          .with_command("rpm -i '#{buildroot}/RPMS/x86_64/#{rpm}'")
      end

      it 'uses the correct rpmbuild args' do
        expect(chef_run).to run_execute('compile postfix from SRPM')
          .with_command(
            "rpmbuild #{rpmbuild_args} --rebuild '#{buildroot}/SRPMS/#{srpm}'"
          )
      end
    end # context on CentOS 7

    context 'with CentOS 6' do
      let(:rpm) { "postfix-2.6.6-6.el6.1.#{node['kernel']['machine']}.rpm" }
      let(:srpm) { 'postfix-2.6.6-6.el6_7.1.src.rpm' }
      let(:rpmbuild_args) { '--define="PGSQL 1"' }
      before do
        node.automatic['platform'] = 'centos'
        node.automatic['platform_version'] = '6.0'
      end

      %w(
        postgresql-devel rpm-build zlib-devel openldap-devel db4-devel
        cyrus-sasl-devel pcre-devel openssl-devel perl-Date-Calc gcc
        mysql-devel pkgconfig ed
      ).each do |pkg|
        it "installs #{pkg} package" do
          expect(chef_run).to install_package(pkg)
        end
      end

      it 'installs the correct RPM' do
        expect(chef_run).to run_execute('install postfix from SRPM')
          .with_command("rpm -i '#{buildroot}/RPMS/x86_64/#{rpm}'")
      end

      it 'uses the correct rpmbuild args' do
        expect(chef_run).to run_execute('compile postfix from SRPM')
          .with_command(
            "rpmbuild #{rpmbuild_args} --rebuild '#{buildroot}/SRPMS/#{srpm}'"
          )
      end

      [
        'CentOS-$releasever - Base Sources',
        'CentOS-$releasever - Updates Sources',
        'CentOS-$releasever - Extras Sources'
      ].each do |repo|
        it "configures #{repo} yum repository at compile time" do
          expect(chef_run).to create_yum_repository(repo).at_compile_time
        end
      end
    end # context on CentOS 6

    context 'with Fedora' do
      let(:rpm) { "foobar-1.0_19.#{node['kernel']['machine']}.tar.gz" }
      let(:rpmbuild_args) { '--with=pgsql' }
      before do
        node.automatic['platform'] = 'fedora'
        node.automatic['platform_version'] = '6.0'
      end

      %w(
        postgresql-devel rpm-build zlib-devel openldap-devel libdb-devel
        cyrus-sasl-devel pcre-devel openssl-devel perl-Date-Calc gcc
        mariadb-devel pkgconfig ed tar libicu-devel sqlite-devel tinycdb-devel
      ).each do |pkg|
        it "installs #{pkg} package" do
          expect(chef_run).to install_package(pkg)
        end
      end

      it 'installs the correct RPM' do
        expect(chef_run).to run_execute('install postfix from SRPM')
          .with_command("rpm -i '#{buildroot}/RPMS/x86_64/#{rpm}'")
      end

      it 'uses the correct rpmbuild args' do
        expect(chef_run).to run_execute('compile postfix from SRPM')
          .with_command(
            "rpmbuild #{rpmbuild_args} --rebuild '#{buildroot}/SRPMS/#{srpm}'"
          )
      end
    end # context on Fedora

    context 'with Fedora 24' do
      before do
        node.automatic['platform'] = 'fedora'
        node.automatic['platform_version'] = '23.0'
      end

      %w(
        postfix
        postfix-pgsql
      ).each do |pkg|
        it "installs #{pkg} package" do
          expect(chef_run).to install_package(pkg)
        end
      end
    end # context on Fedora 23

    context 'with Amazon' do
      let(:pc_shell_out) { instance_double('Mixlib::ShellOut') }
      let(:gr_shell_out) { instance_double('Mixlib::ShellOut') }
      let(:rpm) { "foobar-1.0_19.#{node['kernel']['machine']}.tar.gz" }
      let(:rpmbuild_args) { '--with=pgsql' }
      before do
        node.automatic['platform'] = 'amazon'
        node.automatic['platform_version'] = '2013.09.2'

        allow(Mixlib::ShellOut).to receive(:new)
          .with('postconf -m | grep -qFw pgsql').and_return(pc_shell_out)
        allow(pc_shell_out).to receive(:run_command).and_return(pc_shell_out)
        allow(pc_shell_out).to receive(:error?).and_return(true)

        allow(Mixlib::ShellOut).to receive(:new)
          .with(
            'yum install postfix > /dev/null 2>&1 && '\
            'yes | get_reference_source -p postfix | '\
              'grep "^Corresponding source RPM to found package : " | '\
              'sed "s/^Corresponding source RPM to found package : //"'
          ).and_return(gr_shell_out)
        allow(gr_shell_out).to receive(:run_command).and_return(gr_shell_out)
        allow(gr_shell_out).to receive(:error!)
        allow(gr_shell_out).to receive(:stdout)
          .and_return(srpm)
      end

      it 'searches the source using get_reference_source' do
        expect(Mixlib::ShellOut).to receive(:new).once
          .with(
            'yum install postfix > /dev/null 2>&1 && '\
            'yes | get_reference_source -p postfix | '\
              'grep "^Corresponding source RPM to found package : " | '\
              'sed "s/^Corresponding source RPM to found package : //"'
          ).and_return(gr_shell_out)
        chef_run
      end

      it 'checks get_reference_source for errors' do
        expect(gr_shell_out).to receive(:error!)
        chef_run
      end

      it 'creates /root/rpmbuild/SRPMS directory' do
        expect(chef_run).to create_directory('/root/rpmbuild/SRPMS')
          .with_recursive(true)
      end

      it 'links SRPM to /usr/src/srpm/debug/' do
        expect(chef_run).to create_link("/root/rpmbuild/SRPMS/#{srpm}")
          .with_to("/usr/src/srpm/debug/#{srpm}")
      end

      %w(
        postgresql-devel rpm-build zlib-devel openldap-devel db4-devel
        cyrus-sasl-devel pcre-devel openssl-devel perl-Date-Calc gcc
        mysql-devel pkgconfig ed
      ).each do |pkg|
        it "installs #{pkg} package" do
          expect(chef_run).to install_package(pkg)
        end
      end

      it 'installs the correct RPM' do
        expect(chef_run).to run_execute('install postfix from SRPM')
          .with_command("rpm -i '#{buildroot}/RPMS/x86_64/#{rpm}'")
      end

      it 'uses the correct rpmbuild args' do
        expect(chef_run).to run_execute('compile postfix from SRPM')
          .with_command(
            "rpmbuild #{rpmbuild_args} --rebuild '#{buildroot}/SRPMS/#{srpm}'"
          )
      end
    end # context on Amazon

    context 'with Scientific 7' do
      let(:rpm) { "postfix-2.10.1-6.el7.#{node['kernel']['machine']}.rpm" }
      let(:srpm) { 'postfix-2.10.1-6.el7.src.rpm' }
      let(:rpmbuild_args) { '--with=pgsql' }
      before do
        node.automatic['platform'] = 'scientific'
        node.automatic['platform_version'] = '7.0'
      end

      %w(
        postgresql-devel rpm-build zlib-devel libdb-devel
        cyrus-sasl-devel pcre-devel openssl-devel perl-Date-Calc gcc
        mariadb-devel pkgconfig ed tar systemd-sysv
      ).each do |pkg|
        it "installs #{pkg} package" do
          expect(chef_run).to install_package(pkg)
        end
      end

      it 'installs the correct RPM' do
        expect(chef_run).to run_execute('install postfix from SRPM')
          .with_command("rpm -i '#{buildroot}/RPMS/x86_64/#{rpm}'")
      end

      it 'uses the correct rpmbuild args' do
        expect(chef_run).to run_execute('compile postfix from SRPM')
          .with_command(
            "rpmbuild #{rpmbuild_args} --rebuild '#{buildroot}/SRPMS/#{srpm}'"
          )
      end
    end # context on Scientific 7
  end # context on RPM platforms

  context 'with APT platforms' do
    before { node.automatic['platform'] = 'ubuntu' }

    it 'installs postfix package' do
      expect(chef_run).to install_package('postfix')
    end

    it 'installs postfix-pgsql package' do
      expect(chef_run).to install_package('postfix-pgsql')
    end
  end

  context 'with Unknown platforms' do
    before { node.automatic['platform'] = 'unknown' }

    it 'installs postfix package' do
      expect(chef_run).to install_package('postfix')
    end
  end # context on APT platforms
end
