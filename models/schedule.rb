module Illuminati
  module Models
    class Schedule
      include Mongoid::Document

      field :on, type: Boolean
      field :bri, type: Integer
      field :huesat, type: Hash
      field :alert, type: String
      field :xy, type: Hash
      field :transitiontime, type: Integer
      field :time, type: DateTime
      field :cron, type: Hash

      def light_state
        state = {}
        if !on.nil? then state['on'] = on end
        if !bri.nil? then state['bri'] = bri end
        if !alert.nil? then state['alert'] = alert end
        if !transitiontime.nil? then
          state['transitiontime'] = transitiontime
        end
        if !huesat.nil? and !huesat['hue'].nil? and !huesat['sat'].nil? then
          state['hue'] = huesat['hue']
          state['sat'] = huesat['sat']
        end
        if !xy.nil? and !xy['x'].nil? and !xy['y'].nil? then
          state['xy'] = [xy['x'], xy['y']]
        end
        state
      end
    end
  end
end
