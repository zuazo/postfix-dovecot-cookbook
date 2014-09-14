# CHANGELOG for postfix-dovecot

This file is used to list changes made in each version of `postfix-dovecot`.

## 0.3.0:

* `.kitchen.local.yml`.example renamed to `.kitchen.ses.yml`.
* Ensure */etc/mailname* file creation.
* `Gemfile`: some gem versions updated.
* `kitchen.yml`: updated to support latest test-kitchen format.
* `README`: Amazon SES Tests section: KITCHEN_LOCAL_YAML variable value fixed.
* Added Fedora and Amazon Linux support.
* Added `kitchen.cloud.yml` file
* `postfix-dovecot_test` metadata: added name.
* `kitchen.yml`: Added forwarded port and `recipe[apt]` to the runlist.
* Depends on `postfixadmin` cookbook version `< 1.0.0`.

## 0.2.0:

* Added [Amazon SES](http://aws.amazon.com/ses/) support.
 * Added SES tests.
* Fixed *resolv.conf* inside chroot in CentOS.

## 0.1.0:

* Initial release of `postfix-dovecot`

