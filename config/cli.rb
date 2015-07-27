$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'models'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'boot'

ENV['RACK_ENV'] ||= 'test'
Bundler.require(:default, ENV['RACK_ENV'])

['../../config/initializers/*.rb', '../../models/*.rb'].each do |path|
  Dir[File.expand_path(path, __FILE__)].each do |f|
    require f
  end
end
