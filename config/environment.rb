ENV['RACK_ENV'] ||= 'test'
ENV['illuminati.logpath'] ||= '/tmp/illuminati.log'
ENV['illuminati.lightsconfigpath'] ||= '/home/illuminati/.lightsconfig'

require File.expand_path('../application', __FILE__)
