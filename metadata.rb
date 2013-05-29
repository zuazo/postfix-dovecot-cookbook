name             'postfix-dovecot'
maintainer       'Onddo Labs, Sl.'
maintainer_email 'team@onddo.com'
license          'Apache 2.0'
description      'Installs/Configures postfix-dovecot'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

supports 'centos'
supports 'debian'
supports 'ubuntu'

depends 'dovecot'
depends 'onddo-spamassassin'
depends 'postfixadmin'
depends 'postfix-full'

