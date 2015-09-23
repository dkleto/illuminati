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
        @hue.set_group_state(0,b)
      end
    end
  end
end
