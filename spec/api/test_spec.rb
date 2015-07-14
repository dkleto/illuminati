require 'spec_helper'

describe Illuminati::API do
  include Rack::Test::Methods

  def app
    Illuminati::API
  end

  it 'returns a test response' do
    get '/api/test'
    expect(last_response.status).to eq(200)
    expect(last_response.body).to eq({ test: 'test' }.to_json)
  end
end
