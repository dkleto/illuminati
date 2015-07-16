require 'spec_helper'

describe Illuminati::API do
  include Rack::Test::Methods

  def app
    Illuminati::API
  end

  context "with no schedule events" do
    it 'returns an empty collection of schedule events' do
      get '/api/schedules'
      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq("[]")
    end
  end
  context "with schedule events" do
    schedule1 = {
                   :command => "Make some crazy change",
                   :transition_time => 2,
                   :time => Time.now,
                   :repeat => true,
                   :cron_minute => '30',
                   :cron_hour => '17',
                   :cron_day => '*',
                   :cron_month => '*',
                   :cron_weekday => '1'
                 }
    Illuminati::Models::Schedule.create!(schedule1)
    it "returns the collection of schedule events" do
      get '/api/schedules'
      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq([schedule1].to_json)
    end
  end
end
