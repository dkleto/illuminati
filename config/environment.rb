ENV['RACK_ENV'] ||= 'test'
ENV['illuminati.logpath'] ||= '/tmp/illuminati.log'

require File.expand_path('../application', __FILE__)
