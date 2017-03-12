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

  describe 'when an email is sent through smtp' do
    let(:from) { 'from@foobar.com' }
    let(:to) { 'blackhole@zuazo.org' }
    let(:pattern) do
      "postfix/smtp.* to=<#{to}>, relay=.*.amazonaws.com.*, .*status=sent"
    end
    let(:mail_log) do
      if ::File.exist?('/var/log/maillog')
        '/var/log/maillog'
      else
        '/var/log/mail.log'
      end
    end
    before(:context) { send_email(from, to) }

    it 'is able to receive it', retry: 30, retry_wait: 1 do
      expect(::File.read(mail_log)).to include pattern
    end
  end
end
