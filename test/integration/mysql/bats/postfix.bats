#!/usr/bin/env bats

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin

@test "postfix should be running" {
  ps axu | grep -q 'postfi[x]'
}

@test "postconf should run without errors" {
  /usr/sbin/postconf > /dev/null
}

@test "master should be listening on smtp" {
  lsof -itcp:'smtp' -a -c'master'
}

@test "master should be listening on ssmtp" {
  lsof -itcp:'465' -a -c'master'
}

@test "master should be listening on submission" {
  lsof -itcp:'submission' -a -c'master'
}

@test "should be able to login using submission (plain)" {
  /opt/chef/embedded/bin/ruby "${BATS_TEST_DIRNAME}/helpers/submission_plain.rb"
}

@test "should be able to receive mails through smtp" {
  FINGERPRINT="G27XB6yIyYyM99Tv8UXW$(date +%s)"
  TIMEOUT='30'
  MAIL_DIR='/var/vmail/foobar.com/postmaster/new'
  /opt/chef/embedded/bin/ruby "${BATS_TEST_DIRNAME}/helpers/smtp_send.rb" "${FINGERPRINT}"
  i='0'
  while [ "${i}" -le "${TIMEOUT}" ] \
    && ! ( [ -e "${MAIL_DIR}/" ] && grep -qF "${FINGERPRINT}" "${MAIL_DIR}"/* )
  do
    [ "${i}" -gt '0' ] && sleep 1
    i="$((i+1))"
  done
  grep -qF "${FINGERPRINT}" "${MAIL_DIR}"/*
}
