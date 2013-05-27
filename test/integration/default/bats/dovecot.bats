#!/usr/bin/env bats

@test "dovecot should be running" {
  ps axu | grep -q 'doveco[t]'
}

@test "doveconf should run without errors" {
  doveconf > /dev/null
}

