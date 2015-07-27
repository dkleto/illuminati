require 'rubygems'

ENV['RACK_ENV'] ||= 'test'

require File.expand_path('../../config/cli', __FILE__)

RSpec.configure do |config|
  config.mock_with :rspec
  config.expect_with :rspec
  config.raise_errors_for_deprecations!
  config.before :each do
    Mongoid.purge!
  end
  config.after :all do
    Mongoid.default_session.drop
  end
end
