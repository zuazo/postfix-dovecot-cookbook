# encoding: UTF-8
#
# Author:: Xabier de Zuazo (<xabier@zuazo.org>)
# Copyright:: Copyright (c) 2013 Onddo Labs, SL.
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

require 'net/smtp'

module Helpers
  # Test helpers to send emails via SMTP
  module PostfixDovecotTest
    include MiniTest::Chef::Assertions
    include MiniTest::Chef::Context
    include MiniTest::Chef::Resources

    def template(from, to)
      <<-EOM
From: #{from}
To: #{to}
Subject: Some cool subject for testing

A blackhole email body.

EOM
    end

    def send_test_mail(from, to)
      Net::SMTP.start('localhost', 25) do |smtp|
        smtp.send_message(
          template(from, to),
          from,
          to
        )
      end
    end
  end
end
