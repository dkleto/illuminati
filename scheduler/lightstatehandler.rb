module Illuminati
  class LightStateHandler
    def initialize(hue, schedule)
      @hue = hue
      @schedule = schedule
    end

    def call(job, time)
      if @hue.nil? then
        $logger.error "No lights object provided"
        nil
      else
        b = BulbState.new(@schedule.light_state)
        begin
          response = @hue.set_group_state(0,b)
        rescue StandardError => e
          $logger.error "Error contacting the Hue API: " + e.message
        end
      end
    end
  end
end
