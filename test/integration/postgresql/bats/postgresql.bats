#!/usr/bin/env bats

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin

@test "postgresql should be running" {
  ps axu | grep -q 'postmaste[r]'
}

@test "postgresql should be listening" {
  lsof -itcp:'postgres' -a -c'postmaster'
}
