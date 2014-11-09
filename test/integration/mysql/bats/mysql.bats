#!/usr/bin/env bats

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin

@test "mysqld is running" {
  ps axu | grep -q 'mysql[d]'
}

@test "mysqld is listening" {
  lsof -itcp:'mysql' -a -c'mysqld'
}
