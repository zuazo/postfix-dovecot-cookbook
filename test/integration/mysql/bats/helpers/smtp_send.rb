# encoding: UTF-8

require 'net/smtp'
unless ARGV[0]
  puts 'Usage:'
  puts "  #{$PROGRAM_NAME} FINGERPRINT"
  exit 1
end
msgstr = <<-EOM
Subject: Some cool subject for testing

A hamish email body.

Fingerprint: #{ARGV[0]}
EOM
Net::SMTP.start('localhost', 25) do |smtp|
  smtp.send_message(
    msgstr,
    'team@onddo.com',
    'postmaster@foobar.com'
  )
end
