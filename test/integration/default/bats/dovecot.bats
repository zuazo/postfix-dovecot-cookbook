#!/usr/bin/env bats

@test "dovecot should be running" {
  ps axu | grep -q 'doveco[t]'
}

@test "doveconf should run without errors" {
  doveconf > /dev/null
}

@test "should be able to login using imap (plain)" {
  /opt/chef/embedded/bin/ruby "${BATS_TEST_DIRNAME}/helpers/imap-plain.rb"
}

