$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'api'))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'scheduler'))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'app'))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'models'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'boot'

Bundler.require(:default, ENV['RACK_ENV'])

dependencies = ['../../config/initializers/*.rb', '../../models/*.rb',
                '../../api/*.rb', '../../scheduler/*.rb',
                '../../lights/lights.rb']

dependencies.each do |path|
  Dir[File.expand_path(path, __FILE__)].each do |f|
    require f
  end
end

file_opts = File::WRONLY | File::APPEND | File::CREAT
$logger = Logger.new(File.open(ENV['illuminati.logpath'], file_opts))
if ENV['RACK_ENV'] == 'production' then
  $logger.level = Logger::INFO
else
  $logger.level = Logger::DEBUG
end

hue = Illuminati.load_lights(ENV['illuminati.lightsconfigpath'], $logger)

require 'api'
require 'illuminati_app'

scheduler = Illuminati::Scheduler.new(Rufus::Scheduler.singleton, hue)
scheduler.sync
