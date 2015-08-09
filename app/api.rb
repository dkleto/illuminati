module Illuminati
  class API < Grape::API
    prefix 'api'
    format :json
    mount ::Illuminati::Schedule
    add_swagger_documentation
  end
end
