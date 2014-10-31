# encoding: UTF-8
#
# Cookbook Name:: postfix-dovecot
# Recipe:: postfix_postgresql
#
# Copyright 2014, Onddo Labs, Sl.
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

case node['platform']
when 'debian', 'ubuntu'
  package 'postfix'
  package 'postfix-pgsql'
when 'centos', 'fedora', 'redhat', 'amazon', 'scientific'

  node['postfix-dovecot']['postfix']['srpm']['packages'].each do |pkg|
    package pkg
  end

  repos = node.default['postfix-dovecot']['yum'].keys

  # TODO: use yum-centos cookbook
  repos.each do |repo|
    # compile time action required for yumdownloader
    yum_repository node['postfix-dovecot']['yum'][repo]['name'] do
      repositoryid repo
      baseurl node['postfix-dovecot']['yum'][repo]['baseurl']
      gpgcheck node['postfix-dovecot']['yum'][repo]['gpgcheck']
      enabled node['postfix-dovecot']['yum'][repo]['enabled']
      gpgkey node['postfix-dovecot']['yum'][repo]['gpgkey']
    end.run_action(:create)
  end

  buildroot = '/root/rpmbuild'

  if %w(amazon).include?(node['platform'])

    srpm =
      if Mixlib::ShellOut.new('postconf -m | grep -qFw pgsql')
         .run_command.error?
        cmd = Mixlib::ShellOut.new(
          'yum install postfix > /dev/null 2>&1 && '\
          'yes | get_reference_source -p postfix | '\
            'grep "^Corresponding source RPM to found package : " | '\
            'sed "s/^Corresponding source RPM to found package : //"'
        ).run_command
        cmd.error!
        cmd.stdout.split("\n")[-1]
      end
    fail 'Sources for postfix RPM not found.' if srpm.nil?

    directory "#{buildroot}/SRPMS" do
      recursive true
    end

    link "#{buildroot}/SRPMS/#{srpm}" do
      to "/usr/src/srpm/debug/#{srpm}"
    end

  else # !amazon

    # required for yumdownload
    package('yum-utils').run_action(:install)

    cmd = Mixlib::ShellOut.new('yumdownloader --source --urls postfix')
          .run_command
    cmd.error!
    url = cmd.stdout.split("\n")[-1]

    srpm = ::File.basename(url)

    execute 'yumdownloader postfix' do
      command "yumdownloader --source --destdir=#{buildroot}/SRPMS postfix"
      creates "#{buildroot}/SRPMS/#{srpm}"
    end

  end

  rpm_regexp = node['postfix-dovecot']['postfix']['srpm']['rpm_regexp']
  rpm = rpm_regexp.nil? ? srpm : srpm.sub(rpm_regexp[0], rpm_regexp[1])

  yum_package 'postfix (without postgresql)' do
    package_name 'postfix'
    not_if 'postconf -m | grep -qFw pgsql'
    action :remove
  end

  # TODO: do not compile as root
  rpmbuild_args = node['postfix-dovecot']['postfix']['srpm']['rpm_build_args']
  execute 'compile postfix from SRPM' do
    command "rpmbuild #{rpmbuild_args} --rebuild '#{buildroot}/SRPMS/#{srpm}'"
    environment('HOME' => '/root')
    not_if { rpm.nil? || srpm.nil? }
    creates "#{buildroot}/RPMS/#{node['kernel']['machine']}/#{rpm}"
  end

  execute 'install postfix from SRPM' do
    command "rpm -i '#{buildroot}/RPMS/#{node['kernel']['machine']}/#{rpm}'"
    not_if { rpm.nil? }
    not_if 'rpm -q postfix'
  end

else
  package 'postfix'
end
