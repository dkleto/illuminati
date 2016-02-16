require 'api_helper'

describe Illuminati::API do
  include Rack::Test::Methods

  def app
    Illuminati::API
  end

  # Set up the data for test schedule events.
  let(:job_1_hash) {
        {
          :label => 'Hue/saturation job',
          :on => true,
          :bri => 255,
          :xy => {'x' => 0.1, 'y' => 0.6},
          :transitiontime => 0,
          :alert => 'none',
          :time => DateTime.new(2015, 07, 18, 0, 0, 0),
          :cron => {'minute' => '30', 'hour' => '17', 'day' => '*',
                    'month' => '*', 'weekday' => '1,6'}
        }
  }
  let(:job_2_hash) {
    {
        :label => 'XY job',
        :on => true,
        :bri => 100,
        :xy => {"x" => 0.5, "y" => 0.8},
        :transitiontime => 15,
        :alert => 'lselect',
        :time => DateTime.new(2015, 07, 18, 0, 0, 0),
    }
  }
  let(:update_job_hash) {
      {
        :on => false,
        :transitiontime => 2,
      }
  }
  let(:clear_cron_hash) {
      {
        :clear_cron => true
      }
  }
  let(:update_xy_hash) {
      {
        :xy => {"x" => 1, "y" => 0.01},
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
      post_params = Rack::Utils.build_nested_query(job_2_hash)
      post_string = '/api/schedule?' + post_params

      expect {
        post post_string
        expect(last_response.status).to eq(201)
      }.to change(Illuminati::Models::Schedule, :count).by(1)
      schedule = Illuminati::Models::Schedule.last
      expect(schedule).to have_attributes(job_2_hash)
    end

  end

  context "with schedule event" do
    before do |each|
      @schedule1 = Illuminati::Models::Schedule.create(job_1_hash)
      @schedule2 = Illuminati::Models::Schedule.create!(job_2_hash)
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
      expected = job_1_hash.merge(update_job_hash).stringify_keys
      expect(schedule).to have_attributes(expected)
    end

    it "accepts clear_cron and removes cron values" do
      put_params = Rack::Utils.build_nested_query(clear_cron_hash)
      put_string = "/api/schedule/#{@schedule1.id}?" + put_params

      put put_string
      @schedule1.reload
      schedule = Illuminati::Models::Schedule.find_by(_id: @schedule1.id)
      expect(schedule.cron).to be_nil
    end

    it "removes a schedule event based on ID" do
      expect {
        delete "/api/schedule/#{@schedule1.id}"
        expect(last_response.status).to eq(200)
      }.to change(Illuminati::Models::Schedule, :count).by(-1)
    end
  end
end
