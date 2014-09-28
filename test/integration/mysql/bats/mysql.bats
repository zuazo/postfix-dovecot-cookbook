#!/usr/bin/env bats

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin

@test "mysql should be running" {
  lsof -cmysqld -a -iTCP:mysql
}
