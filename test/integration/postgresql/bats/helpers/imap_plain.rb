# encoding: UTF-8

require 'net/imap'
imap = Net::IMAP.new('localhost')
imap.authenticate('PLAIN', 'postmaster@foobar.com', 'p0stm@st3r1')
imap.examine('INBOX')
imap.close
