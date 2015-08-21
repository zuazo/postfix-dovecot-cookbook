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

require 'spec_helper'

describe 'postfix-dovecot::vmail' do
  let(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe) }

  it 'creates vmail user' do
    expect(chef_run).to create_user('vmail')
      .with_comment('Vmail')
      .with_home('/var/vmail')
      .with_shell('/bin/false')
      .with_uid(5000)
      .with_supports(manage_home: true)
      .with_system(true)
  end

  it 'creates vmail group' do
    expect(chef_run).to create_group('vmail')
      .with_gid(5000)
      .with_members(%w(vmail))
      .with_system(true)
      .with_append(true)
  end
end
