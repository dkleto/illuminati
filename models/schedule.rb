module Illuminati
  module Models
    class Schedule
      include Mongoid::Document

      field :on, type: Boolean
      field :bri, type: Integer
      field :alert, type: String
      field :xy, type: Hash
      field :transitiontime, type: Integer
      field :time, type: DateTime
      field :cron, type: Hash
      field :label, type: String

      def light_state
        state = {}
        if !on.nil? then state['on'] = on end
        if !bri.nil? then state['bri'] = bri end
        if !alert.nil? then state['alert'] = alert end
        if !transitiontime.nil? then
          state['transitiontime'] = transitiontime
        end
        if !xy.nil? and !xy['x'].nil? and !xy['y'].nil? then
          state['xy'] = [xy['x'], xy['y']]
        end
        state
      end
    end
  end
end
