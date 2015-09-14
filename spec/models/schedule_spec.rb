require 'unit_helper'

require File.expand_path('../../../models/schedule.rb', __FILE__)

describe Illuminati::Models::Schedule do
  let(:fields) {
    {
      :on => true, :bri => 255, :huesat => {'hue' => 35000, 'sat' => 255},
      :alert => 'none', :xy => {'x' => 0.5, 'y' => 0.7}, :transitiontime => 5,
      :time => DateTime.now
    }
  }
  let(:schedule) do
    stub_model Illuminati::Models::Schedule, fields
  end
  
  it "returns a state change hash with only the relevant state fields" do
    valid_fields = ['on', 'bri', 'hue', 'sat', 'alert', 'xy', 'transitiontime']
    expect(schedule.light_state).to be_a_kind_of(Hash)
    expect(schedule.light_state.keys).to match_array(valid_fields)
  end

  it "returns a state change hash with on, bri, alert and transitiontime" do
    test_fields = ['on', 'bri', 'alert', 'transitiontime']
    test_hash = fields.clone.keep_if {|k,_| test_fields.include? k}
    expect(schedule.light_state).to have_attributes(test_hash)
  end

  it "returns a state change hash with separate hue and sat fields" do
    expect(schedule.light_state['hue']).to eql(fields[:huesat]['hue'])
    expect(schedule.light_state['sat']).to eql(fields[:huesat]['sat'])
  end

  it "returns a state change hash with xy values as an array" do
    xy_array = [fields[:xy]['x'], fields[:xy]['y']]
    expect(schedule.light_state['xy']).to match_array(xy_array)
  end
end
