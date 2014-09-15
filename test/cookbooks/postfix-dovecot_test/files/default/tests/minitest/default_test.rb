# encoding: UTF-8

require File.expand_path('../support/helpers', __FILE__)

describe 'postfix-dovecot::default' do
  include Helpers::PostfixDovecotTest

  describe 'postfix' do

    it 'postfix should be running' do
      service('postfix').must_be_running
    end

    it 'should be able to send mails through SES' do
      skip unless node['postfix-dovecot']['ses']['enabled']
      send_test_mail(node['postfix-dovecot']['ses']['email'], 'to@blackhole.io')
    end

  end

  describe 'dovecot' do
    it 'dovecot should be running' do
      service('dovecot').must_be_running
    end
  end

end
