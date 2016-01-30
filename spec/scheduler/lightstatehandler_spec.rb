require 'unit_helper'

require File.expand_path('../../../scheduler/lightstatehandler.rb', __FILE__)
require File.expand_path('../../../models/schedule.rb', __FILE__)

describe 'lightstatehandler object' do
  let(:test_state) {
    {
      'on' => true, 'bri' => 255, 'hue' => 35000, 'sat' => 255,
      'alert' => 'none', 'transitiontime' => 5, 'reachable' => true
    }
  }
  let(:schedule) do
    instance_double('Illuminati::Models::Schedule', :light_state => test_state)
  end

  let(:logger) {
    Illuminati.logger(ENV['illuminati.logpath'], ENV['RACK_ENV'])
  }

  it 'does nothing if lights object is nil' do
    handler = Illuminati::LightStateHandler.new(nil, schedule, logger)
    expect(handler.call(nil, nil)).to be_nil
  end

  it 'attempts to set light state' do
    lights = instance_double('Lights', :set_group_state => true)
    handler = Illuminati::LightStateHandler.new(lights, schedule, logger)
    expect(lights).to receive(:set_group_state).with(0, instance_of(BulbState))
    handler.call(nil, nil)
  end
end
