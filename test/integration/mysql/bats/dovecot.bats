#!/usr/bin/env bats

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin

@test "dovecot should be running" {
  ps axu | grep -q 'doveco[t]'
}

@test "doveconf should run without errors" {
  doveconf > /dev/null
}

@test "dovecot should be listening on imap" {
  lsof -itcp:'imap' -a -c'dovecot'
}

@test "dovecot should be listening on imaps" {
  lsof -itcp:'imaps' -a -c'dovecot'
}

@test "should be able to login using imap (plain)" {
  /opt/chef/embedded/bin/ruby "${BATS_TEST_DIRNAME}/helpers/imap_plain.rb"
}
