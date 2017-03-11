# encoding: UTF-8
# -*- mode: ruby -*-
# vi: set ft=ruby :

# More info at http://bundler.io/gemfile.html
#
# Many of the gem versions installed here are based on the versions installed
# by ChefDK.

source 'https://rubygems.org'

chef_version = ENV.key?('CHEF_VERSION') ? ENV['CHEF_VERSION'] : nil

group :doc do
  gem 'yard', '~> 0.9.5'
end

group :test do
  gem 'rake'
  gem 'berkshelf', '~> 5.0'
end

group :style do
  gem 'foodcritic', '~> 6.3.0'
  gem 'rubocop', '= 0.40.0'
end

group :unit do
  gem 'chef', chef_version unless chef_version.nil?
  gem 'chefspec', '~> 6.0'
  gem 'simplecov', '~> 0.13.0'
  gem 'should_not', '~> 1.1'
  gem 'chef-vault', '~> 2.3'
  gem 'chef-encrypted-attributes', '~> 0.4'
end

group :integration do
  gem 'test-kitchen', '~> 1.13'
end

group :integration_docker do
  gem 'kitchen-docker', '~> 2.1'
end

group :integration_vagrant do
  gem 'vagrant-wrapper', '~> 2.0'
  gem 'kitchen-vagrant', '~> 1.0'
end

group :integration_cloud do
  gem 'kitchen-ec2', '~> 1.2'
  gem 'kitchen-digitalocean', '~> 0.9.5'
end

group :guard do
  gem 'guard', '~> 2.14'
  gem 'guard-foodcritic', '~> 2.1'
  gem 'guard-rubocop', '~> 1.1'
  gem 'guard-rspec', '~> 4.3'
  # Temporary disabled: Error is: cannot load such file -- guard/kitchen
  # gem 'guard-kitchen', '~> 0.0'
end

group :travis do
  gem 'coveralls', '~> 0.7', require: false
end
