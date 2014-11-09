#!/usr/bin/env bats

@test "postfix has mysql enabled" {
  postconf -m | grep -Fq 'mysql'
}
