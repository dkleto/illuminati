module Illuminati
  class API < Grape::API
    prefix 'api'
    format :json
    mount ::Illuminati::Schedule
  end
end
