#\ -o 0.0.0.0
require File.expand_path('../config/environment', __FILE__)
require 'rack/cors'

use Rack::Cors do
  allow do
    origins '*'
    resource '/api/lights/all', headers: :any, methods: [:put, :options]
    resource '/api/schedule*', headers: :any, methods: [:get, :post, :delete, :put, :options]
    resource '/api/schedules', headers: :any, methods: [:get, :options]
  end
end

run Illuminati::App.instance
