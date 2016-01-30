module Illuminati
  class Scheduler
    def initialize(scheduler, hue = nil, logger)
      @schedule = Illuminati::Models::Schedule
      @scheduler = scheduler
      @hue = hue
      @logger = logger
    end

    def sync
      repeat_jobs = @schedule.where(:cron.ne => nil)
      onceoff_jobs = @schedule.any_of({:cron => nil},
                                      {:cron.exists => false})

      onceoff_jobs.each do |job|
        handler = LightStateHandler.new(@hue, job, @logger)
        @scheduler.at job[:time].to_s, handler
      end
      repeat_jobs.each do |job|
        cron_string = "#{job[:cron][:minute]} #{job[:cron][:hour]} " +
                      "#{job[:cron][:day]} #{job[:cron][:month]} " +
                      "#{job[:cron][:weekday]}"
        if job[:time] > DateTime.now then
          handler = LightStateHandler.new(@hue, job, @logger)
          @scheduler.cron cron_string, handler, {:first_at => job[:time]}
        else
          handler = LightStateHandler.new(@hue, job, @logger)
          @scheduler.cron cron_string, handler
        end
      end
    end

    def clear
      @scheduler.jobs.each(&:unschedule)
    end
  end
end
