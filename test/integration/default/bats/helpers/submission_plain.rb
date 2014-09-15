# encoding: UTF-8

require 'net/smtp'

smtp = Net::SMTP.new 'localhost', 587
ctx = OpenSSL::SSL::SSLContext.new
ctx.verify_mode = OpenSSL::SSL::VERIFY_NONE
smtp.enable_starttls(ctx)
smtp.start(
  'onddo.com', 'postmaster@foobar.com', 'p0stm@st3r1', :plain
) do |_smtp|
  puts 'OK'
end
