$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'api'))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'scheduler'))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'app'))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'models'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'boot'

Bundler.require(:default, ENV['RACK_ENV'])

dependencies = ['../../config/initializers/*.rb', '../../models/*.rb',
                '../../api/*.rb', '../../scheduler/*.rb']

dependencies.each do |path|
  Dir[File.expand_path(path, __FILE__)].each do |f|
    require f
  end
end

logger = Illuminati.logger(ENV['illuminati.logpath'], ENV['RACK_ENV'])

hue = Illuminati.load_lights(ENV['illuminati.lightsconfigpath'], logger)

require 'api'
require 'illuminati_app'

scheduler = Illuminati::Scheduler.new(Rufus::Scheduler.singleton, hue, logger)
scheduler.sync
