# encoding: UTF-8
#
# Cookbook Name:: postfix-dovecot_test
# Recipe:: postgresql_memory
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

def getconf(var)
  cmd = Mixlib::ShellOut.new("getconf #{var}").run_command
  cmd.error!
  cmd.stdout.split("\n")[-1]
end

if node['postgresql']['version'].to_f <= 9.3 &&
   node['platform'] != 'scientific'
  page_size = getconf('PAGE_SIZE').to_i
  phys_pages = getconf('_PHYS_PAGES').to_i

  shmall = phys_pages / 2
  shmmax = shmall * page_size

  execute 'sysctl -p /etc/sysctl.d/postgresql.conf' do
    action :nothing
  end

  template '/etc/sysctl.d/postgresql.conf' do
    source 'sysctl.conf.erb'
    variables(
      values: {
        'kernel.shmall' => shmall,
        'kernel.shmmax' => shmmax
      }
    )
    only_if { ::File.exist?('/etc/sysctl.d') }
    notifies :run, 'execute[sysctl -p /etc/sysctl.d/postgresql.conf]',
             :immediately
  end
end
