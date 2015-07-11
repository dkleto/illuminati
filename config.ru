#\ -p 80 -o 0.0.0.0
require File.expand_path('../config/environment', __FILE__)

run Illuminati::App.instance
