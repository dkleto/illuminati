ENV['RACK_ENV'] ||= 'test'
ENV['illuminati.logpath'] ||= '/var/log/sitelogs/illuminati/illuminati.log'

require File.expand_path('../application', __FILE__)
