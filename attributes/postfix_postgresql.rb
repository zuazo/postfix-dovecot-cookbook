# encoding: UTF-8
#
# Cookbook Name:: postfix-dovecot
# Attributes:: postfix_postgresql
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

releasever = node['platform_version'].to_i # TODO: avoid this
yum_default = node.default['postfix-dovecot']['yum']
srpm_default = node.default['postfix-dovecot']['postfix']['srpm']

if %w(centos scientific).include?(node['platform'])
  if node['platform_version'].to_i >= 7
    srpm_default['packages'] = %w(
      postgresql-devel rpm-build zlib-devel openldap-devel libdb-devel
      cyrus-sasl-devel pcre-devel openssl-devel perl-Date-Calc gcc
      mariadb-devel pkgconfig ed tar systemd-sysv
    )
    if node['platform'] == 'scientific'
      srpm_default['rpm_regexp'] = [
        /\.src\./, ".#{node['kernel']['machine']}."
      ]
    else
      srpm_default['rpm_regexp'] = [
        /\.src\./, ".#{node['platform']}.#{node['kernel']['machine']}."
      ]
    end
    srpm_default['rpm_build_args'] = '--with=pgsql'
  else
    srpm_default['packages'] = %w(
      postgresql-devel rpm-build zlib-devel openldap-devel db4-devel
      cyrus-sasl-devel pcre-devel openssl-devel perl-Date-Calc gcc
      mysql-devel pkgconfig ed tar
    )
    srpm_default['rpm_regexp'] = [
      /_[0-9]+(\.[0-9]+)?\.src\./, "\\1.#{node['kernel']['machine']}."
    ]
    srpm_default['rpm_build_args'] = '--define="PGSQL 1"'

    yum_default['base-source']['name'] = 'CentOS-$releasever - Base Sources'
    yum_default['base-source']['baseurl'] =
      'http://vault.centos.org/centos/$releasever/os/Source/'
    yum_default['base-source']['gpgcheck'] = true
    yum_default['base-source']['enabled'] = false
    yum_default['base-source']['gpgkey'] =
      "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-#{releasever}"

    yum_default['updates-source']['name'] =
      'CentOS-$releasever - Updates Sources'
    yum_default['updates-source']['baseurl'] =
      'http://vault.centos.org/centos/$releasever/updates/Source/'
    yum_default['updates-source']['gpgcheck'] = true
    yum_default['updates-source']['enabled'] = false
    yum_default['updates-source']['gpgkey'] =
      "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-#{releasever}"

    yum_default['extras-source']['name'] = 'CentOS-$releasever - Extras Sources'
    yum_default['extras-source']['baseurl'] =
      'http://vault.centos.org/centos/$releasever/extras/Source/'
    yum_default['extras-source']['gpgcheck'] = true
    yum_default['extras-source']['enabled'] = false
    yum_default['extras-source']['gpgkey'] =
      "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-#{releasever}"
  end
elsif %w(fedora redhat).include?(node['platform'])
  # Uses MariaDB since fedora 19
  # TODO: test with older versions
  srpm_default['packages'] = %w(
    postgresql-devel rpm-build zlib-devel openldap-devel libdb-devel
    cyrus-sasl-devel pcre-devel openssl-devel perl-Date-Calc gcc
    mariadb-devel pkgconfig ed tar libicu-devel sqlite-devel tinycdb-devel
  )

  srpm_default['rpm_regexp'] = [
    /\.src\./, ".#{node['kernel']['machine']}."
  ]
  srpm_default['rpm_build_args'] = '--with=pgsql'
elsif %w(amazon).include?(node['platform'])
  # TODO: this does not work, postfix source needs to be patched to support
  # linux3 kernels:
  # http://patches.netspiders.net/postfix/postfix-2.6.6-linux3.patch
  # http://patches.netspiders.net/postfix/postfix-2.6.6-linux3.spec.patch
  srpm_default['packages'] = %w(
    postgresql-devel rpm-build zlib-devel openldap-devel db4-devel
    cyrus-sasl-devel pcre-devel openssl-devel perl-Date-Calc gcc
    mysql-devel pkgconfig ed tar
  )
  srpm_default['rpm_regexp'] = [
    /\.src\./, ".#{node['kernel']['machine']}."
  ]
  srpm_default['rpm_build_args'] = '--with=pgsql'
end
