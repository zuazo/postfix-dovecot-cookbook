# CHANGELOG for postfix-dovecot

This file is used to list changes made in each version of `postfix-dovecot`.

## 1.0.0 (2014-10-07):

* **Update Warnings:**:
 * Ruby `>= 1.9.3` required.
 * Chef `>= 11.14.2` required.
 * Rename `::postfix_full` recipe to `::postfix`.

* Update to work with `postfixadmin` cookbook `1.0.0`.
* Integrate with `ssl_certificate` cookbook.
* Fix hostname attribute default value when FQDN is not set.
* Move *test/kitchen/cookbooks* directory to *test/cookbooks*.
* Fix all *RuboCop* offenses.
* `README`:
 * Separate `README` file in multiple files.
 * Add some badges.
 * Some small documentation fixes.
 * `TESTING`: replace old DIGITALOCEAN_CLIENT_ID with DIGITALOCEAN_ACCESS_TOKEN.
* Add some basic *ChefSpec* recipe tests and a `Rakefile`.
* Add `.travis.yml` file.
* Improve Postfix chroot file creation, based on `postfix-full` master code.
* Set `common_name` for PostfixAdmin and Postfix SSL certs.
* `kitchen.yml`:
 * Images update.
 * `kitchen.cloud.yml`: remove all `DIGITAL_OCEAN_` env variables.
 * Add minitest-handler again.
  * Fix minitest test mail template.
* Add PostgreSQL support.
* `metadata`: use pessimistic version constraints.
* `Gemfile`:
 * Replace `vagrant` by `vagrant-wrapper`.
 * Berkshelf update to `3.1`.
* `Berkfile`: use a generic Berksfile template.
* Add `Guardfile`.
* `Vagrantfile`:
 * Update to work properly.
 * Document it in TESTING.
* Use `#default_unless` instead of `#set_unless`.
* `::postfixadmin` recipe: remove `#set_unless` usage.
* Add *Serverspec* tests and more *bats* tests.
* Define PATH in some integration tests, recommended to use `lsof`.
* Integration tests improvement to support more platforms.
* Fix Debian/Ubuntu PostgreSQL support using the `locale` cookbook.
* Improve PostgreSQL support in RPM platforms including tests.
* Add `rubocop.yml` file: include some ruby files related with Chef.

## 0.3.0 (2014-09-14):

* `.kitchen.local.yml`.example renamed to `.kitchen.ses.yml`.
* Ensure */etc/mailname* file creation.
* `Gemfile`: some gem versions updated.
* `kitchen.yml`: updated to support latest test-kitchen format.
* `README`: Amazon SES Tests section: KITCHEN_LOCAL_YAML variable value fixed.
* Added Fedora and Amazon Linux support.
* Added `kitchen.cloud.yml` file.
* `postfix-dovecot_test` metadata: added name.
* `kitchen.yml`: Added forwarded port and `recipe[apt]` to the runlist.
* Depends on `postfixadmin` cookbook version `< 1.0.0`.

## 0.2.0 (2013-08-09):

* Added [Amazon SES](http://aws.amazon.com/ses/) support.
 * Added SES tests.
* Fixed *resolv.conf* inside chroot in CentOS.

## 0.1.0 (2013-06-16):

* Initial release of `postfix-dovecot`.
