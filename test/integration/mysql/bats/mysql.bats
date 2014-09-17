#!/usr/bin/env bats

@test "mysql should be running" {
  LSOF="$(which lsof || true)"
  [ x"${LSOF}" = x ] && LSOF='/usr/sbin/lsof'
  "${LSOF}" -cmysqld -a -iTCP:mysql
}
