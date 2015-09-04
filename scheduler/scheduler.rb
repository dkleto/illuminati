module Illuminati
  class Scheduler
    def initialize(scheduler, hue = nil)
      @schedule = Illuminati::Models::Schedule
      @scheduler = scheduler
      @hue = hue
    end

    def sync
      repeat_jobs = @schedule.where(:cron.ne => nil)
      onceoff_jobs = @schedule.any_of({:cron => nil},
                                      {:cron.exists => false})

      onceoff_jobs.each do |job|
        handler = LightStateHandler.new(@hue, job)
        @scheduler.at job[:time].to_s, handler
      end
      repeat_jobs.each do |job|
        cron_string = "#{job[:cron][:minute]} #{job[:cron][:hour]} " +
                      "#{job[:cron][:day]} #{job[:cron][:month]} " +
                      "#{job[:cron][:weekday]}"
        if job[:time] > DateTime.now then
          handler = LightStateHandler.new(@hue, job)
          @scheduler.cron cron_string, handler, {:first_at => job[:time]}
        else
          handler = LightStateHandler.new(@hue, job)
          @scheduler.cron cron_string, handler
        end
      end
    end

    def clear
      @scheduler.jobs.each(&:unschedule)
    end
  end

  class LightStateHandler
    def initialize(hue, schedule)
      @hue = hue
      @schedule = schedule
    end

    def call(job, time)
      if @hue.nil? then
        #TODO: Log this error properly.
        puts "No lights object provided."
      else
        b = BulbState.new(@schedule.light_state)
        @hue.set_group_state(0,b)
      end
    end
  end
end
