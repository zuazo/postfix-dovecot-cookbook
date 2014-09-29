#!/usr/bin/env bats

@test "postfix should have postgresql enabled" {
  postconf -c /etc/postfix -m | grep -Fq 'pgsql'
}
