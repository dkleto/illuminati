ENV['RACK_ENV'] ||= 'test'
ENV['illuminati.logpath'] ||= '/var/log/illuminati/app.log'

require File.expand_path('../application', __FILE__)
