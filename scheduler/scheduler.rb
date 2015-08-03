module Illuminati
  class Scheduler
    def initialize(scheduler)
      @schedule = Illuminati::Models::Schedule
      repeat_jobs = @schedule.where(
          :time.gte => DateTime.now, :repeat => true)
      onceoff_jobs = @schedule.where(
          :time.gte => DateTime.now, :repeat => false)
      @scheduler = scheduler

      onceoff_jobs.each do |job|
        @scheduler.at job[:time].to_s do
          puts job[:command]
        end
      end
      repeat_jobs.each do |job|
        cron_string = "#{job[:cron_minute]} #{job[:cron_hour] }" +
                      "#{job[:cron_day]} #{job[:cron_month] }" +
                      "#{job[:cron_weekday]}"
        @scheduler.cron cron_string, :first_at => job[:time] do
          puts job[:command]
        end
      end
    end
  end
end
