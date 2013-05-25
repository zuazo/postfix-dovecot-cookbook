# -*- mode: ruby -*-
# vi: set ft=ruby :

site :opscode

metadata
cookbook 'apt'
cookbook 'yum'
cookbook 'ark', git: 'git://github.com/bryanwb/chef-ark.git' # bug https://github.com/bryanwb/chef-ark/issues/35
cookbook 'dovecot', path: '../dovecot'
cookbook 'postfixadmin', path: '../postfixadmin'
cookbook 'postfix-full', git: 'git://github.com/mswart/chef-postfix-full.git'
cookbook 'postfix-dovecot_test', path: "./test/kitchen/cookbooks/postfix-dovecot_test"

