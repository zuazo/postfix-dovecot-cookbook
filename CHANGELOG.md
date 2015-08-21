# CHANGELOG for postfix-dovecot

This file is used to list changes made in each version of `postfix-dovecot`.

## v2.0.0 (2015-08-18)

* Update RuboCop to `0.29.1` (new offenses fixed).
* Fix ChefSpec unit tests to work with latest chef-vault cookbook.
* Gemfile: Fix Ruby `1.9` support.
* Update some cookbook dependencies:
  * [...]
* Gemfile: Update RuboCop version to `0.30.1`.

## v1.2.0 (2015-01-09)

* Add Dovecot SSL certificate generation.
* Integrate with `ssl_certificate` cookbook version `1.2`.
* metadata: Fix attributes default types.
* Gemfile: Update RuboCop to `0.28.0`.
* README: Fix some typos and update Supermarket links.

## v1.1.0 (2014-11-09)

* Add RBL support.
* Improve SES support:
 * Read the SES credentials from chef vault bag.
 * Add `node['postfix-dovecot']['ses']['region']` attribute.
 * Update SES servers.
 * Fix integration tests.
* Allow postfix configuration (tables and master.cf) to be modfied easily.
* `::dovecot` recipe: Fix password reading with encrypt attributes enabled.
* Create Postfix tables directory, required by SES.
* metadata: update to use `dovecot` cookbook version `2`.
* Simplify `smtp_tls_CAfile` attribute case.
* Fix new RuboCop offenses.
* Integrate unit tests with `should_not` gem.
* Enable ChefSpec coverage and **100%** covered.
* Add Gemfile for Serverspec integration tests.
* Remove rubocop.yml, not needed with RuboCop `0.27.0`.
* Berksfile:
 * Fix minitest cookbook include.
 * Remove *-cookbook* sufix.
* Homogenize license headers.
* README:
 * Use single quotes in examples.
 * Use markdown tables.
 * Fix *Usage Examples* title.
* TODO: Add tasks for DSPAM and CLamAV.

## v1.0.0 (2014-10-07)

* **Update Warnings:**:
 * Ruby `>= 1.9.3` required.
 * Chef `>= 11.14.2` required.
 * Rename `::postfix_full` recipe to `::postfix`.

* Update to work with `postfixadmin` cookbook `1.0.0`.
* Integrate with `ssl_certificate` cookbook.
* Fix hostname attribute default value when FQDN is not set.
* Move *test/kitchen/cookbooks* directory to *test/cookbooks*.
* Fix all *RuboCop* offenses.
* README:
 * Separate README file in multiple files.
 * Add some badges.
 * Some small documentation fixes.
 * TESTING: replace old DIGITALOCEAN_CLIENT_ID with DIGITALOCEAN_ACCESS_TOKEN.
* Add some basic *ChefSpec* recipe tests and a Rakefile.
* Add .travis.yml file.
* Improve Postfix chroot file creation, based on `postfix-full` master code.
* Set `common_name` for PostfixAdmin and Postfix SSL certs.
* kitchen.yml:
 * Images update.
 * kitchen.cloud.yml: remove all `DIGITAL_OCEAN_` env variables.
 * Add minitest-handler again.
  * Fix minitest test mail template.
* Add PostgreSQL support.
* metadata: use pessimistic version constraints.
* Gemfile:
 * Replace `vagrant` by `vagrant-wrapper`.
 * Berkshelf update to `3.1`.
* Berkfile: use a generic Berksfile template.
* Add Guardfile.
* Vagrantfile:
 * Update to work properly.
 * Document it in TESTING.
* Use `#default_unless` instead of `#set_unless`.
* `::postfixadmin` recipe: remove `#set_unless` usage.
* Add *Serverspec* tests and more *bats* tests.
* Define PATH in some integration tests, recommended to use `lsof`.
* Integration tests improvement to support more platforms.
* Fix Debian/Ubuntu PostgreSQL support using the `locale` cookbook.
* Improve PostgreSQL support in RPM platforms including tests.
* Add rubocop.yml file: include some ruby files related with Chef.

## v0.3.0 (2014-09-14)

* .kitchen.local.yml.example renamed to .kitchen.ses.yml.
* Ensure */etc/mailname* file creation.
* Gemfile: some gem versions updated.
* kitchen.yml: updated to support latest test-kitchen format.
* README: Amazon SES Tests section: KITCHEN_LOCAL_YAML variable value fixed.
* Added Fedora and Amazon Linux support.
* Added kitchen.cloud.yml file.
* `postfix-dovecot_test` metadata: added name.
* kitchen.yml: Added forwarded port and `recipe[apt]` to the runlist.
* Depends on `postfixadmin` cookbook version `< 1.0.0`.

## v0.2.0 (2013-08-09)

* Added [Amazon SES](http://aws.amazon.com/ses/) support.
 * Added SES tests.
* Fixed *resolv.conf* inside chroot in CentOS.

## v0.1.0 (2013-06-16)

* Initial release of `postfix-dovecot`.
