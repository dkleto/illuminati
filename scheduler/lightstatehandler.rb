module Illuminati
  class LightStateHandler
    def initialize(hue, schedule, logger)
      @hue = hue
      @schedule = schedule
      @logger = logger
    end

    def call(job, time)
      if @hue.nil? then
        @logger.error "No lights object provided"
        nil
      else
        b = BulbState.new(@schedule.light_state)
        begin
          @hue.set_group_state(0,b)
        rescue StandardError => e
          @logger.error "Error contacting the Hue API: " + e.message
          nil
        end
      end
    end
  end
end
