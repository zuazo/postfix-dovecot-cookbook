#!/usr/bin/env bats

@test "local web server returns PostfixAdmin application" {
  wget -qO- localhost | grep -qF 'Postfix Admin'
}
