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

describe file('/etc/ssl/certs/postfix.pem') do
  it { should be_file }
  it { should be_mode 644 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

describe file('/etc/ssl/private/postfix.key') do
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
  etc/resolv.conf
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
