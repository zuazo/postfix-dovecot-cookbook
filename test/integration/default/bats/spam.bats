#!/usr/bin/env bats

@test 'spamc should be installed' {
  which spamc
}

@test 'spamd should be running' {
  ps axu | grep -q 'spam[d]'
}

@test 'should detect spam correctly' {
  GTUBE='XJS*C4JDBQADN1.NSBN3*2IDNEN*GTUBE-STANDARD-ANTI-UBE-TEST-EMAIL*C.34X'
  echo "${GTUBE}" | spamc | grep -qF 'X-Spam-Flag: YES'
}

@test "should filter spam correctly" {
  GTUBE='XJS*C4JDBQADN1.NSBN3*2IDNEN*GTUBE-STANDARD-ANTI-UBE-TEST-EMAIL*C.34X'
  FINGERPRINT="${GTUBE} - $(date +%s)"
  TIMEOUT='30'
  SPAM_DIR='/var/vmail/foobar.com/postmaster/.Spam/new'
  /opt/chef/embedded/bin/ruby "${BATS_TEST_DIRNAME}/helpers/smtp-send.rb" "${FINGERPRINT}"
  i='0'
  while [ "${i}" -le "${TIMEOUT}" ] \
    && ! ( [ -e "${SPAM_DIR}/" ] && grep -qF "${FINGERPRINT}" "${SPAM_DIR}"/* )
  do
    [ "${i}" -gt '0' ] && sleep 1
    i="$((i+1))"
  done
  grep -qF "${FINGERPRINT}" "${SPAM_DIR}"/*
}

