#!/usr/bin/env bats

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin

@test "mysqld should be running" {
  ps axu | grep -q 'mysql[d]'
}

@test "mysqld should be listening" {
  lsof -itcp:'mysql' -a -c'mysqld'
}
