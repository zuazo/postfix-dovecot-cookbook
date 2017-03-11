# CHANGELOG for postfix-dovecot

This file is used to list changes made in each version of `postfix-dovecot`.

## Unreleased
### Added
- metadata: Add `chef_version`.
- README: Add github and license badges.

### Changed
- Update some cookbook versions:
  - `chef-vault` from `1` to `2`.
  - `dovecot` from `2` to `3`.
  - `postfixadmin` from `2` to `3` (fixes [issue #7](https://github.com/zuazo/postfix-dovecot-cookbook/issues/7), thanks [Arunderwood](https://github.com/arunderwood) for reporting).
  - `ssl_certificate` from `1` to `2`.
  - `yum` from `3` to `5`.
- Dovecot: enable SSL explicitly.
- Update RuboCop to version `0.40` and fix new offenses.

### Removed
- Drop Chef `< 12.5` support.
- Drop Ruby `< 2.2` support.
- Metadata: Remove grouping ([RFC-85](https://github.com/chef/chef-rfc/blob/8d47f1d0afa5a2313ed2010e0eda318edc28ba47/rfc085-remove-unused-metadata.md)).
- README: Remove documentation about locale (old).

## v2.0.1 (2015-09-03)

* Fix typo in `-f` argument to `/usr/lib/dovecot/deliver` ([issue #5](https://github.com/zuazo/postfix-dovecot-cookbook/pull/5), thanks [Uwe Stuehler](https://github.com/ustuehler)).

## v2.0.0 (2015-08-22)

* **Breaking changes**:
 * Update the `postfixadmin` cookbook to version `2` ([See the `postfixadmin` cookbook CHANGELOG for the update process](https://github.com/zuazo/postfixadmin-cookbook/blob/master/CHANGELOG.md#upgrading-from-a-1xy-cookbook-release)).
 * Update `onddo-spamassassin` cookbook to version `1` ([See the `postfixadmin` cookbook CHANGELOG for the update process](https://github.com/onddo/spamassassin-cookbook/blob/master/CHANGELOG.md#v100-2015-04-29)).

* New features:
 * metadata: Add `source_url` and `issues_url`.

* Documentation:
 * Update chef links to use *chef.io* domain.
 * Update contact information and links after migration.
 * README: Put the cookbook name in the title.

* Testing:
 * Fix ChefSpec unit tests to work with latest chef-vault cookbook.
 * Use SoloRunner in some ChefSpec tests to make them faster.
 * Move ChefSpec tests to *test/unit*.
 * Travis: run tests against Chef `11` and Chef `12`.
 * Add Debian `8` to test-kitchen tests.
 * Kitchen tests: fix MySQL password.
 * Minitest: remove some redundant tests.
 * Gemfile:
  * Fix Ruby `1.9` support.
  * Update RuboCop to `0.33.0`.

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
