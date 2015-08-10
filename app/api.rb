module Illuminati
  class API < Grape::API
    prefix 'api'
    format :json
    mount ::Illuminati::Schedule
    add_swagger_documentation hide_format: true
  end
end
