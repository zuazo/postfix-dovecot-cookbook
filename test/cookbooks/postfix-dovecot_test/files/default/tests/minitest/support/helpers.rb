# encoding: UTF-8

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
