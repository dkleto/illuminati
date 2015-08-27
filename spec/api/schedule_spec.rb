require 'api_helper'

describe Illuminati::API do
  include Rack::Test::Methods

  def app
    Illuminati::API
  end

  # Set up the data for test schedule events.
  let(:huesat_job_hash) {
        {
          :on => true,
          :bri => 255,
          :huesat => {"hue" => 10000, "sat" => 100},
          :transitiontime => 0,
          :alert => 'none',
          :time => DateTime.new(2015, 07, 18, 0, 0, 0),
          :repeat => true,
          :cron_minute => '30',
          :cron_hour => '17',
          :cron_day => '*',
          :cron_month => '*',
          :cron_weekday => '1,6'
        }
  }
  let(:xy_job_hash) {
    {
        :on => true,
        :bri => 100,
        :xy => {"x" => 0.5, "y" => 0.8},
        :transitiontime => 15,
        :alert => 'lselect',
        :time => DateTime.new(2015, 07, 18, 0, 0, 0),
        :repeat => false
    }
  }
  let(:update_job_hash) {
      {
        :on => false,
        :transitiontime => 2
      }
  }

  context "with no schedule events" do

    it 'returns an empty collection of schedule events' do
      get '/api/schedules'
      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq("[]")
    end

    it 'returns 404 when accessing nonexistent schedule event' do
      get "/api/schedule/1"
      expect(last_response.status).to eq(404)
    end

    it 'fails to update a nonexistent schedule event' do
      put '/api/schedule/1'
      expect(last_response.status).to eq(404)
    end

    it 'returns 404 when deleting nonexistent schedule event' do
      delete '/api/schedule/lkj98737'
      expect(last_response.status).to eq(404)
    end

    it 'creates a new schedule event' do
      post_params = Rack::Utils.build_nested_query(huesat_job_hash)
      post_string = '/api/schedule?' + post_params

      expect {
        post post_string
        expect(last_response.status).to eq(201)
      }.to change(Illuminati::Models::Schedule, :count).by(1)
      schedule = Illuminati::Models::Schedule.last
      huesat_job_hash.each do |key, value|
        expect(schedule[key]).to eq(value)
      end
    end

    let(:invalid_job_hash) {
      {
          :on => true,
          :bri => 100,
          :xy => {"x" => 0.1, "y" => 0.9},
          :huesat => {"hue" => 100, "sat" => 50},
          :transitiontime => 15,
          :alert => 'lselect',
          :time => DateTime.new(2015, 07, 18, 0, 0, 0),
          :repeat => false
      }
    }
    it 'refuses to create an event with both huesat and xy params' do
      post_params = Rack::Utils.build_nested_query(invalid_job_hash)
      post_string = '/api/schedule?' + post_params

      expect {
        post post_string
        expect(last_response.status).to eq(400)
      }.to_not change(Illuminati::Models::Schedule, :count)

    end
  end

  context "with schedule event" do
    before do |each|
      @schedule1 = Illuminati::Models::Schedule.create(huesat_job_hash)
      @schedule2 = Illuminati::Models::Schedule.create!(xy_job_hash)
    end

    it "returns the collection of schedule events" do
      get '/api/schedules'
      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq([@schedule1, @schedule2].to_json)
    end

    it "returns a specific schedule event based on ID" do
      get "/api/schedule/#{@schedule1.id}"
      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq(@schedule1.to_json)
    end

    it "updates a schedule event based on ID" do
      put_params = Rack::Utils.build_nested_query(update_job_hash)
      put_string = "/api/schedule/#{@schedule1.id}?" + put_params

      expect {
        put put_string
        expect(last_response.status).to eq(200)
      }.to_not change(Illuminati::Models::Schedule, :count)
      @schedule1.reload
      schedule = Illuminati::Models::Schedule.find_by(_id: @schedule1.id)
      expect(schedule).to be_truthy
      huesat_job_hash.merge(update_job_hash).each do |key, value|
        expect(schedule[key]).to eq(value)
      end
    end

    it "removes a schedule event based on ID" do
      expect {
        delete "/api/schedule/#{@schedule1.id}"
        expect(last_response.status).to eq(200)
      }.to change(Illuminati::Models::Schedule, :count).by(-1)
    end
  end
end
