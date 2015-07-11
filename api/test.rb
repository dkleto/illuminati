module Illuminati
  class Test < Grape::API
    format :json
    get '/test' do
        { test: 'test' }
    end
  end
end
