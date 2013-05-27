#!/usr/bin/env bats

@test "postfix should be running" {
  ps axu | grep -q 'postfi[x]'
}

@test "postconf should run without errors" {
  /usr/sbin/postconf > /dev/null
}

