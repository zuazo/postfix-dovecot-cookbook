#!/usr/bin/env bats

@test "local web server should return PostfixAdmin application" {
  wget -qO- localhost | grep -qF 'Postfix Admin'
}
