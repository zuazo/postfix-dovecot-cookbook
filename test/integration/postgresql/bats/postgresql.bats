#!/usr/bin/env bats

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin

@test "postgresql is running" {
  ps axu | grep -q 'postgre[s]'
}
