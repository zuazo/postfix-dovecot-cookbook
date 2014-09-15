# encoding: UTF-8

require 'net/smtp'
msgstr = <<-EOM
Subject: Some cool subject for testing

A blackhole email body.

EOM
Net::SMTP.start('localhost', 25) do |smtp|
  smtp.send_message(
    msgstr,
    'from@foobar.com',
    'to@blackhole.io'
  )
end
