#!/usr/bin/env bats

@test "postfix should be running" {
  ps axu | grep -q 'postfi[x]'
}

@test "postconf should run without errors" {
  /usr/sbin/postconf > /dev/null
}

@test "should be able to login using submission (plain)" {
  /opt/chef/embedded/bin/ruby "${BATS_TEST_DIRNAME}/helpers/submission-plain.rb"
}

@test "should be able to receive mails through smtp" {
  FINGERPRINT="G27XB6yIyYyM99Tv8UXW$(date +%s)"
  TIMEOUT='10'
  /opt/chef/embedded/bin/ruby "${BATS_TEST_DIRNAME}/helpers/smtp-send-ham.rb" "${FINGERPRINT}"
  i='0'
  while [ "${i}" -le "${TIMEOUT}" ] && ! grep -qF "${FINGERPRINT}" /home/vmail/foobar.com/postmaster/new/*
  do
    [ "${i}" -gt '0' ] && sleep 1
    i="$((i+1))"
  done
  grep -qF "${FINGERPRINT}" /home/vmail/foobar.com/postmaster/new/*
}

