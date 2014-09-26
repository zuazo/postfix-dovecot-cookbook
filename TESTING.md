Testing
=======

## Requirements

* `vagrant`
* `foodcritic`
* `rubocop`
* `berkshelf`
* `chefspec`
* `test-kitchen`
* `kitchen-vagrant`

You must have [VirtualBox](https://www.virtualbox.org/) and [Vagrant](http://www.vagrantup.com/) installed.

You can install gem dependencies with bundler:

    $ gem install bundler
    $ bundle install

## Running the Syntax Style Tests

    $ bundle exec rake style

## Running the Unit Tests

    $ bundle exec rake unit

## Running the Integration Tests

    $ bundle exec rake integration

Or:

    $ bundle exec kitchen list
    $ bundle exec kitchen test
    [...]

### Running Integration Tests in the Cloud

#### Requirements

* `kitchen-vagrant`
* `kitchen-digitalocean`
* `kitchen-ec2`

You can run the tests in the cloud instead of using vagrant. First, you must set the following environment variables:

* `AWS_ACCESS_KEY_ID`
* `AWS_SECRET_ACCESS_KEY`
* `AWS_KEYPAIR_NAME`: EC2 SSH public key name. This is the name used in Amazon EC2 Console's Key Pars section.
* `EC2_SSH_KEY_PATH`: EC2 SSH private key local full path. Only when you are not using an SSH Agent.
* `DIGITALOCEAN_CLIENT_ID`
* `DIGITALOCEAN_API_KEY`
* `DIGITALOCEAN_SSH_KEY_IDS`: DigitalOcean SSH numeric key IDs.
* `DIGITALOCEAN_SSH_KEY_PATH`: DigitalOcean SSH private key local full path. Only when you are not using an SSH Agent.

Then, you must configure test-kitchen to use `.kitchen.cloud.yml` configuration file:

    $ export KITCHEN_LOCAL_YAML=".kitchen.cloud.yml"
    $ bundle exec kitchen list
    [...]

## Amazon SES Tests

You need to set the following environment variables:

* `AMAZON_SES_EMAIL_FROM`: SES valid from address, only used in tests
* `AMAZON_SES_SMTP_USERNAME`: See [Obtaining Your Amazon SES SMTP Credentials](http://docs.aws.amazon.com/ses/latest/DeveloperGuide/smtp-credentials.html) documentation.
* `AMAZON_SES_SMTP_PASSWORD`

Then, you must configure test-kitchen to use [.kitchen.ses.yml](/blob/master/.kitchen.ses.yml) configuration file:

```
$ export AMAZON_SES_EMAIL_FROM="no-reply@sesdomain.com"
$ export AMAZON_SES_SMTP_USERNAME="..."
$ export AMAZON_SES_SMTP_PASSWORD="..."
$ export KITCHEN_LOCAL_YAML=".kitchen.ses.yml"
$ bundle exec kitchen list
[...]
```
