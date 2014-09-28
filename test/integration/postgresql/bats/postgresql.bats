#!/usr/bin/env bats

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin

@test "postgresql should be running" {
  lsof -cpostmaster -a -iTCP:postgres
}
