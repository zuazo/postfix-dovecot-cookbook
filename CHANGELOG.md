# Change Log
All notable changes to the `postfix-dovecot` cookbook will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/) and this project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]
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
- CHANGELOG: Follow "Keep a CHANGELOG".

### Removed
- Drop Chef `< 12.5` support.
- Drop Ruby `< 2.2` support.
- Metadata: Remove grouping ([RFC-85](https://github.com/chef/chef-rfc/blob/8d47f1d0afa5a2313ed2010e0eda318edc28ba47/rfc085-remove-unused-metadata.md)).
- README: Remove documentation about locale (old).

### Fixed
- Fix PostgreSQL support on CentOS and Fedora.
- Fix Chef `13` deprecation warnings.

## [2.0.1] - 2015-09-03
### Fixed
- Fix typo in `-f` argument to `/usr/lib/dovecot/deliver` ([issue #5](https://github.com/zuazo/postfix-dovecot-cookbook/pull/5), thanks [Uwe Stuehler](https://github.com/ustuehler)).

## [2.0.0] - 2015-08-22
### Changed
- Update the `postfixadmin` cookbook to version `2` ([See the `postfixadmin` cookbook CHANGELOG for the update process](https://github.com/zuazo/postfixadmin-cookbook/blob/master/CHANGELOG.md#upgrading-from-a-1xy-cookbook-release)).
- Update `onddo-spamassassin` cookbook to version `1` ([See the `postfixadmin` cookbook CHANGELOG for the update process](https://github.com/onddo/spamassassin-cookbook/blob/master/CHANGELOG.md#v100-2015-04-29)).
- Update chef links to use *chef.io* domain.
- Update contact information and links after migration.
- Update RuboCop to `0.33.0`.

### Added
- metadata: Add `source_url` and `issues_url`.
- README: Put the cookbook name in the title.

## [1.2.0] - 2015-01-09
### Added
- Add Dovecot SSL certificate generation.
- Integrate with `ssl_certificate` cookbook version `1.2`.

### Changed
- Gemfile: Update RuboCop to `0.28.0`.

### Fixed
- metadata: Fix attributes default types.
- README: Fix some typos and update Supermarket links.

## [1.1.0] - 2014-11-09
### Added
- Add RBL support.
- Allow postfix configuration (tables and master.cf) to be modfied easily.
- Create Postfix tables directory, required by SES.

### Changed
- Improve SES support:
 - Read the SES credentials from chef vault bag.
 - Add `node['postfix-dovecot']['ses']['region']` attribute.
 - Update SES servers.
- metadata: update to use `dovecot` cookbook version `2`.
- Simplify `smtp_tls_CAfile` attribute case.
- Homogenize license headers.
- README:
  - Use single quotes in examples.
  - Use markdown tables.
  - Fix *Usage Examples* title.

### Fixed
- `::dovecot` recipe: Fix password reading with encrypt attributes enabled.
- Fix new RuboCop offenses.

## [1.0.0] - 2014-10-07
### Added
- Integrate with `ssl_certificate` cookbook.
- Add PostgreSQL support.

### Changed
- Rename `::postfix_full` recipe to `::postfix`.
- Update to work with `postfixadmin` cookbook `1.0.0`.
- Improve Postfix chroot file creation, based on `postfix-full` master code.
- Set `common_name` for PostfixAdmin and Postfix SSL certs.
- metadata: use pessimistic version constraints.
- Use `#default_unless` instead of `#set_unless`.
- `::postfixadmin` recipe: remove `#set_unless` usage.
- README:
  - Separate README file in multiple files.
  - Add some badges.
  - Some small documentation fixes.

### Removed
- Drop Ruby `< 1.9.3` support.
- Drop Chef `< 11.14.2` support.

### Fixed
- Fix hostname attribute default value when FQDN is not set.
- Fix all *RuboCop* offenses.

## [0.3.0] - 2014-09-14
### Added
- Ensure */etc/mailname* file creation.
- Add Fedora and Amazon Linux support.

### Changed
- Depends on `postfixadmin` cookbook version `< 1.0.0`.
- README: Amazon SES Tests section: KITCHEN_LOCAL_YAML variable value fixed.

## [0.2.0] - 2013-08-09
### Added
- Add [Amazon SES](http://aws.amazon.com/ses/) support.
  - Add SES tests.

### Fixed
- Fix *resolv.conf* inside chroot in CentOS.

## 0.1.0 - 2013-06-16

- Initial release of `postfix-dovecot`.

[Unreleased]: https://github.com/zuazo/postfix-dovecot-cookbook/compare/2.0.1...HEAD
[2.0.1]: https://github.com/zuazo/postfix-dovecot-cookbook/compare/2.0.0...2.0.1
[2.0.0]: https://github.com/zuazo/postfix-dovecot-cookbook/compare/1.2.0...2.0.0
[1.2.0]: https://github.com/zuazo/postfix-dovecot-cookbook/compare/1.1.0...1.2.0
[1.1.0]: https://github.com/zuazo/postfix-dovecot-cookbook/compare/1.0.0...1.1.0
[1.0.0]: https://github.com/zuazo/postfix-dovecot-cookbook/compare/0.3.0...1.0.0
[0.3.0]: https://github.com/zuazo/postfix-dovecot-cookbook/compare/0.2.0...0.3.0
[0.2.0]: https://github.com/zuazo/postfix-dovecot-cookbook/compare/0.1.0...0.2.0
