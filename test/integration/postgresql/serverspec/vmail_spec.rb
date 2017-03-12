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

describe 'Vmail' do
  describe user('vmail') do
    it { should exist }
    it { should belong_to_group 'vmail' }
    it { should have_uid 5000 }
    it { should have_home_directory '/var/vmail' }
    it { should have_login_shell '/bin/false' }
  end

  describe group('vmail') do
    it { should exist }
    it { should have_gid 5000 }
  end
end
