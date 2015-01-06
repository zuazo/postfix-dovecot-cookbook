#!/usr/bin/env bats

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin

@test "dovecot is running" {
  ps axu | grep -q 'doveco[t]'
}

@test "doveconf runs without errors" {
  doveconf > /dev/null
}

@test "dovecot is listening on imap" {
  lsof -itcp:'imap' -a -c'dovecot'
}

@test "dovecot is listening on imaps" {
  lsof -itcp:'imaps' -a -c'dovecot'
}

@test "connects to imap SSL" {
  echo | openssl s_client -connect 127.0.0.1:imaps
}

@test "connects to imap with starttls" {
  echo | openssl s_client -starttls imap -connect 127.0.0.1:imap
}

@test "is able to login using imap (plain)" {
  /opt/chef/embedded/bin/ruby "${BATS_TEST_DIRNAME}/helpers/imap_plain.rb"
}
