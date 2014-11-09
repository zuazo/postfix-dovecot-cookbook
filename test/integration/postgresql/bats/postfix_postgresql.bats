#!/usr/bin/env bats

@test "postfix has postgresql enabled" {
  postconf -m | grep -Fq 'pgsql'
}
