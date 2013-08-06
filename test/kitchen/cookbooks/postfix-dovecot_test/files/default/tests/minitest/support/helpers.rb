require 'net/smtp'

module Helpers
  module PostfixDovecotTest
    include MiniTest::Chef::Assertions
    include MiniTest::Chef::Context
    include MiniTest::Chef::Resources

    def send_test_mail(from, to)

      msgstr = <<-EOM
Subject: Some cool subject for testing

A blackhole email body.

EOM
      Net::SMTP.start('localhost', 25) do |smtp|
        smtp.send_message(
          msgstr,
          from,
          to
        )
      end

    end

  end
end
