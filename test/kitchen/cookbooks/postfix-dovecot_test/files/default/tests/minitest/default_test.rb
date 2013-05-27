require File.expand_path('../support/helpers', __FILE__)

describe 'postfix-dovecot::default' do
  include Helpers::PostfixDovecotTest

  describe 'postfix' do
    it 'shuold be running' do
      service('postfix').must_be_running
    end
  end

  describe 'dovecot' do
    it 'shuold be running' do
      service('dovecot').must_be_running
    end
  end

end

