Testing
=======

## Installing the Requirements

You must have [VirtualBox](https://www.virtualbox.org/) and [Vagrant](http://www.vagrantup.com/) installed.

You can install gem dependencies with bundler:

    $ gem install bundler
    $ bundle install --without travis

## Generating the Documentation

This will generate the documentation for the source files inside the [*libraries/*](https://github.com/zuazo/kong-cookbook/tree/master/libraries) directory.

    $ bundle exec rake doc

The documentation is included in the source code itself.

## Syntax Style Tests

We use the following tools to test the code style:

* [RuboCop](https://github.com/bbatsov/rubocop#readme)
* [foodcritic](http://www.foodcritic.io/)

To run the tests:

    $ bundle exec rake style

## Unit Tests

We use [ChefSpec](https://github.com/sethvargo/chefspec#readme) and [RSpec](http://rspec.info/) for the unit tests. RSpec is generally used to test the libraries or some Ruby specific code.

The unit test files are placed in the [*test/unit/*](https://github.com/zuazo/kong-cookbook/tree/master/test/unit) directory.

To run the tests:

    $ bundle exec rake unit

## Integration Tests

We use [Test Kitchen](http://kitchen.ci/) to run the tests and the tests are written using [Serverspec](http://serverspec.org/).

The integration test files are placed in the [*test/integration/*](https://github.com/zuazo/kong-cookbook/tree/master/test/integration) directory. Some cookbooks required by this tests are in the [*test/cookbooks/*](https://github.com/zuazo/kong-cookbook/tree/master/test/cookbooks) directory.

To run the tests:

    $ bundle exec rake integration:vagrant

Or:

    $ bundle exec kitchen list
    $ bundle exec kitchen test
    [...]

### Integration Tests in Docker

You can run the integration tests using [Docker](https://www.docker.com/) instead of Vagrant if you prefer.

Of course, you need to have [Docker installed](https://docs.docker.com/engine/installation/).

    $ wget -qO- https://get.docker.com/ | sh

Then use the `integration:docker` rake task to run the tests:

    $ bundle exec rake integration:docker

### Integration Tests in the Cloud

You can run the tests in the cloud instead of using Vagrant. First, you must set the following environment variables:

* `AWS_ACCESS_KEY_ID`
* `AWS_SECRET_ACCESS_KEY`
* `AWS_KEYPAIR_NAME`: EC2 SSH public key name. This is the name used in Amazon EC2 Console's Key Pars section.
* `EC2_SSH_KEY_PATH`: EC2 SSH private key local full path. Only when you are not using an SSH Agent.
* `DIGITALOCEAN_ACCESS_TOKEN`
* `DIGITALOCEAN_SSH_KEY_IDS`: DigitalOcean SSH numeric key IDs.
* `DIGITALOCEAN_SSH_KEY_PATH`: DigitalOcean SSH private key local full path. Only when you are not using an SSH Agent.

Then use the `integration:cloud` rake task to run the tests:

    $ bundle exec rake integration:cloud

## Amazon SES Tests

You need to set the following environment variables:

* `AMAZON_SES_EMAIL_FROM`: SES valid from address, only used in tests.
* `AMAZON_SES_SMTP_USERNAME`: See [Obtaining Your Amazon SES SMTP Credentials](http://docs.aws.amazon.com/ses/latest/DeveloperGuide/smtp-credentials.html) documentation.
* `AMAZON_SES_SMTP_PASSWORD`
* `AMAZON_SES_REGION`: Amazon SES region (optional).

Then, you must configure test-kitchen to use [.kitchen.ses.yml](/.kitchen.ses.yml) configuration file:

    $ export AMAZON_SES_EMAIL_FROM="no-reply@sesdomain.com"
    $ export AMAZON_SES_SMTP_USERNAME="..."
    $ export AMAZON_SES_SMTP_PASSWORD="..."
    $ export AMAZON_SES_REGION="..."
    $ export KITCHEN_LOCAL_YAML=".kitchen.ses.yml"
    $ bundle exec kitchen list
    [...]

## Guard

Guard is a tool that runs the tests automatically while you are making changes to the source files.

To run Guard:

    $ guard

More info at [Guard Readme](https://github.com/guard/guard#readme).

## Available Rake Tasks

There are multiple Rake tasks that you can use to run the tests:

    $ rake -T

See [Rakefile documentation](https://github.com/ruby/rake/blob/master/doc/rakefile.rdoc) for more information.

## Using Vagrant with the Vagrantfile

### Vagrantfile Requirements

* [ChefDK](https://downloads.chef.io/chef-dk/)
* Berkhelf and Omnibus vagrant plugins:
```
$ vagrant plugin install vagrant-berkshelf vagrant-omnibus
```
* The path correctly set for ChefDK:
```
$ export PATH="/opt/chefdk/bin:${PATH}"
```

### Vagrantfile Usage

    $ vagrant up

To run Chef again on the same machine:

    $ vagrant provision

To destroy the machine:

    $ vagrant destroy
