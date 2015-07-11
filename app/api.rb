module Illuminati
  class API < Grape::API
    prefix 'api'
    format :json
    mount ::Illuminati::Test
  end
end
