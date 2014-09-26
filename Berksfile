# encoding: UTF-8
# -*- mode: ruby -*-
# vi: set ft=ruby :

site :opscode

def local_cookbook(name, version = '>= 0.0.0', options = {})
  cookbook(name, version, {
    path: "../../cookbooks/#{name}"
   }.merge(options))
end

metadata
local_cookbook 'postfixadmin'
local_cookbook 'onddo-spamassassin'
cookbook 'minitest-handler'
cookbook 'apt'
cookbook 'yum'
cookbook 'postfix-dovecot_test', path: './test/cookbooks/postfix-dovecot_test'
