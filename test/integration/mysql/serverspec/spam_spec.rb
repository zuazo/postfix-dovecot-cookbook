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
require_relative 'mail_helpers'

family = os[:family].downcase

spamd =
  case family
  when 'debian', 'ubuntu'
    '/usr/sbin/spamd'
  else
    'spamd'
  end

describe 'SpamAssassin' do
  let(:gtube) do
    'XJS*C4JDBQADN1.NSBN3*2IDNEN*GTUBE-STANDARD-ANTI-UBE-TEST-EMAIL*C.34X'
  end

  describe command('which spamc') do
    its(:exit_status) { should eq 0 }
    its(:stderr) { should eq '' }
  end

  describe process(spamd) do
    it { should be_running }
  end

  # TODO: This does not work on Fedora :-/
  it 'detects spam correctly' do # ,if: !::File.exist?('/etc/fedora-release') do
    expect(
      command("echo '#{gtube}' | spamc | grep -qF 'X-Spam-Flag: YES'")
        .exit_status
    ).to eq 0
  end

  describe 'when spam is sent through smtp' do
    gtube =
      'XJS*C4JDBQADN1.NSBN3*2IDNEN*GTUBE-STANDARD-ANTI-UBE-TEST-EMAIL*C.34X'
    fingerprint = "#{gtube} - #{Time.new.to_i}"
    let(:maildir) { '/var/vmail/foobar.com/postmaster' }
    let(:spamdir) { "#{maildir}/.Spam/new" }
    before(:context) { send_email(fingerprint) }

    it 'filters it correctly', retry: 30, retry_wait: 1 do
      expect(all_file_contents("#{spamdir}/*")).to include fingerprint
    end
  end
end
