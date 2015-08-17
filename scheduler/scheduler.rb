module Illuminati
  class Scheduler
    def initialize(scheduler)
      @schedule = Illuminati::Models::Schedule
      @scheduler = scheduler
    end

    def sync
      repeat_jobs = @schedule.where(:repeat => true)
      onceoff_jobs = @schedule.any_of({:repeat => false},
                                      {:repeat => nil},
                                      {:repeat.exists => false})
      onceoff_jobs.each do |job|
        @scheduler.at job[:time].to_s do
          puts job[:command]
        end
      end
      repeat_jobs.each do |job|
        cron_string = "#{job[:cron_minute]} #{job[:cron_hour]} " +
                      "#{job[:cron_day]} #{job[:cron_month]} " +
                      "#{job[:cron_weekday]}"
        if job[:time] > DateTime.now then
          @scheduler.cron cron_string, :first_at => job[:time] do
            puts job[:command]
          end
        else
          @scheduler.cron cron_string do
            puts job[:command]
          end
        end
      end
    end

    def clear
      @scheduler.jobs.each(&:unschedule)
    end
  end
end
