# -*- mode: ruby -*-
# vi: set ft=ruby :

site :opscode

metadata
cookbook 'apt'
cookbook 'yum'
cookbook 'ark', '>= 0.2.4' # bug with Chef 11 (https://github.com/bryanwb/chef-ark/issues/35)
cookbook 'postfix-full', github: 'mswart/chef-postfix-full', ref: 'v0.1.0'
cookbook 'postfix-dovecot_test', path: "./test/kitchen/cookbooks/postfix-dovecot_test"

