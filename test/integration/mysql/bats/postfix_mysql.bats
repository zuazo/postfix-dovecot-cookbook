#!/usr/bin/env bats

@test "postfix should have mysql enabled" {
  postconf -c /etc/postfix -m | grep -Fq 'mysql'
}
