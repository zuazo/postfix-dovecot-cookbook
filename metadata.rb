name             'postfix-dovecot'
maintainer       'Onddo Labs, Sl.'
maintainer_email 'team@onddo.com'
license          'Apache 2.0'
description      'Installs and configures a mail server using Postfix, Dovecot, PostfixAdmin and SpamAssassin.'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

supports 'centos', '>= 6.0'
supports 'debian', '>= 7.0'
supports 'ubuntu', '>= 12.04'

recipe 'postfix-dovecot::default', 'Installs and configures everything.'
recipe 'postfix-dovecot::vmail', 'Creates vmail user.'
recipe 'postfix-dovecot::spam', 'Installs and configures SpamAssassin.'
recipe 'postfix-dovecot::postfix-full', 'Installs and configures Postfix.'
recipe 'postfix-dovecot::postfixadmin', 'Installs and configures PostfixAdmin.'
recipe 'postfix-dovecot::dovecot', 'Installs and configures Dovecot 2.'

depends 'dovecot'
depends 'onddo-spamassassin'
depends 'postfixadmin'
depends 'postfix-full'

attribute 'postfix-dovecot/postmaster_address',
  :display_name => 'postmaster address',
  :description => 'Postmaster mail address.',
  :type => 'string',
  :required => 'recommended',
  :default => '"postmaster@foo.bar"'

attribute 'postfix-dovecot/hostname',
  :display_name => 'hostname',
  :description => 'Hostname.',
  :type => 'string',
  :required => 'recommended',
  :default => 'node["fqdn"]'

grouping 'postfix-dovecot/sieve',
 :title => 'sieve configuration',
 :description => 'Sieve configuration.'

attribute 'postfix-dovecot/sieve/enabled',
  :display_name => 'sieve enabled',
  :description => 'Whether to enable sieve.',
  :type => 'string',
  :required => 'recommended',
  :default => 'true'

attribute 'postfix-dovecot/sieve/global_path',
  :display_name => 'sieve global_path',
  :description => 'Sieve global path.',
  :type => 'string',
  :required => 'optional',
  :default => '"#{default["dovecot"]["conf_path"]}/sieve/default.sieve"'

grouping 'postfix-dovecot/spamc',
 :title => 'spamc configuration',
 :description => 'Spamc configuration.'

attribute 'postfix-dovecot/spamc/enabled',
  :display_name => 'spamc enabled',
  :description => 'Wether to enable SpamAssassin',
  :type => 'string',
  :required => 'optional',
  :default => 'true'

attribute 'postfix-dovecot/spamc/recipe',
  :display_name => 'spamc recipe',
  :description => 'Spamc recipe name to use.',
  :type => 'string',
  :required => 'optional',
  :default => '"onddo-spamassassin"'

grouping 'postfix-dovecot/vmail',
 :title => 'vmail configuration',
 :description => 'Virtual mail system user configuration.'

attribute 'postfix-dovecot/vmail/user',
  :display_name => 'vmail user',
  :description => 'Virtual mail system user name.',
  :type => 'string',
  :required => 'optional',
  :default => '"vmail"'

attribute 'postfix-dovecot/vmail/group',
  :display_name => 'vmail group',
  :description => 'Virtual mail system group name.',
  :type => 'string',
  :required => 'optional',
  :default => 'node["postfix-dovecot"]["vmail"]["user"]'

attribute 'postfix-dovecot/vmail/uid',
  :display_name => 'vmail uid',
  :description => 'Virtual mail system user id.',
  :type => 'string',
  :required => 'optional',
  :default => '5000'

attribute 'postfix-dovecot/vmail/gid',
  :display_name => 'vmail gid',
  :description => 'Virtual mail system group id.',
  :type => 'string',
  :required => 'optional',
  :default => 'node["postfix-dovecot"]["vmail"]["uid"]'

attribute 'postfix-dovecot/vmail/home',
  :display_name => 'vmail home',
  :description => 'Virtual mail user home path.',
  :type => 'string',
  :required => 'optional',
  :default => '"/var/vmail"'

