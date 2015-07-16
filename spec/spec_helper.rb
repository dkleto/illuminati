require 'rubygems'

ENV['RACK_ENV'] ||= 'test'

require 'rack/test'

require File.expand_path('../../config/environment', __FILE__)

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

require 'capybara/rspec'
Capybara.configure do |config|
  config.app = Illuminati::App.new
  config.server_port = 9293
end
