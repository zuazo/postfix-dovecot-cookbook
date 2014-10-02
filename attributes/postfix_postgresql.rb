# encoding: UTF-8

releasever = node['platform_version'].to_i # TODO: avoid this
yum_default = node.default['postfix-dovecot']['yum']
srpm_default = node.default['postfix-dovecot']['postfix']['srpm']

if %w(centos).include?(node['platform'])
  if node['platform_version'].to_i >= 7
    srpm_default['packages'] = %w(
      postgresql-devel rpm-build zlib-devel openldap-devel libdb-devel
      cyrus-sasl-devel pcre-devel openssl-devel perl-Date-Calc gcc
      mariadb-devel
    )
    srpm_default['rpm_regexp'] = [
      /\.src\./, ".centos.#{node['kernel']['machine']}."
    ]
    srpm_default['rpm_build_args'] = '--with=pgsql'
  else
    srpm_default['packages'] = %w(
      postgresql-devel rpm-build zlib-devel openldap-devel db4-devel
      cyrus-sasl-devel pcre-devel openssl-devel perl-Date-Calc gcc
      mysql-devel
    )
    srpm_default['rpm_regexp'] = [
      /_[0-9]+\.src\./, ".#{node['kernel']['machine']}."
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
elsif %w(fedora redhat scientific).include?(node['platform'])
  # Uses MariaDB since fedora 19
  # TODO: test with older versions
  srpm_default['packages'] = %w(
    postgresql-devel rpm-build zlib-devel openldap-devel libdb-devel
    cyrus-sasl-devel pcre-devel openssl-devel perl-Date-Calc gcc
    mariadb-devel
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
    mysql-devel
  )
  srpm_default['rpm_regexp'] = [
    /\.src\./, ".#{node['kernel']['machine']}."
  ]
  srpm_default['rpm_build_args'] = '--with=pgsql'
end
