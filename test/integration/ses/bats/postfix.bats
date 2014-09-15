#!/usr/bin/env bats

@test "postfix should be running" {
  ps axu | grep -q 'postfi[x]'
}

@test "postconf should run without errors" {
  /usr/sbin/postconf > /dev/null
}

@test "should be able to send mails through SES" {
  TIMEOUT='15'
  PATTERN='postfix/smtp.* to=<to@blackhole.io>, relay=.*.amazonaws.com.*, .*status'
  OK_PATTERN="${PATTERN}=sent"
  if [ -e '/var/log/maillog' ]
  then
    MAIL_LOG='/var/log/maillog'
  else
    MAIL_LOG='/var/log/mail.log'
  fi
  i='0'
  while [ "${i}" -le "${TIMEOUT}" ] \
    && ! grep -q "${PATTERN}" "${MAIL_LOG}"
  do
    [ "${i}" -gt '0' ] && sleep 1
    i="$((i+1))"
  done
  grep -q "${OK_PATTERN}" "${MAIL_LOG}"
}
