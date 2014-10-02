#!/usr/bin/env bats

@test "postfix should have postgresql enabled" {
  postconf -m | grep -Fq 'pgsql'
}
