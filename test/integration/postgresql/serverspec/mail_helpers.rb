# encoding: UTF-8
#
# Author:: Xabier de Zuazo (<xabier@zuazo.org>)
# Copyright:: Copyright (c) 2017 Xabier de Zuazo
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

EMAIL_TEMPLATE = <<-EOM
Subject: Some cool subject for testing

A hamish email body.

Fingerprint: %s
EOM
                 .freeze

def send_email(fingerprint)
  msgstr = format(EMAIL_TEMPLATE, fingerprint)
  Net::SMTP.start('localhost', 25) do |smtp|
    smtp.send_message(
      msgstr,
      'team@onddo.com',
      'postmaster@foobar.com'
    )
  end
end

def all_file_contents(path)
  Dir.glob(path).reduce('') do |result, file|
    result + "\n" + File.read(file)
  end
end
