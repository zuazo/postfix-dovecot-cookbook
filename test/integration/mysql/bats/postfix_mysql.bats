#!/usr/bin/env bats

@test "postfix should have mysql enabled" {
  postconf -m | grep -Fq 'mysql'
}
