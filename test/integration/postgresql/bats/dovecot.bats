#!/usr/bin/env bats

@test "dovecot is running" {
  ps axu | grep -q 'doveco[t]'
}

@test "doveconf runs without errors" {
  doveconf > /dev/null
}

@test "is able to login using imap (plain)" {
  /opt/chef/embedded/bin/ruby "${BATS_TEST_DIRNAME}/helpers/imap_plain.rb"
}
