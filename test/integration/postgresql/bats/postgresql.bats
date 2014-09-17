#!/usr/bin/env bats

@test "postgresql should be running" {
  LSOF="$(which lsof || true)"
  [ x"${LSOF}" = x ] && LSOF='/usr/sbin/lsof'
  "${LSOF}" -cpostmaster -a -iTCP:postgres
}
