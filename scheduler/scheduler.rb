module Illuminati
  class Scheduler
    def initialize(scheduler)
      @schedule = Illuminati::Models::Schedule
      @scheduler = scheduler
    end

    def sync
      repeat_jobs = @schedule.where(:cron.ne => nil)
      onceoff_jobs = @schedule.any_of({:cron => nil},
                                      {:cron.exists => false})
      onceoff_jobs.each do |job|
        @scheduler.at job[:time].to_s do
          puts job[:command]
        end
      end
      repeat_jobs.each do |job|
        cron_string = "#{job[:cron][:minute]} #{job[:cron][:hour]} " +
                      "#{job[:cron][:day]} #{job[:cron][:month]} " +
                      "#{job[:cron][:weekday]}"
        if job[:time] > DateTime.now then
          @scheduler.cron cron_string, :first_at => job[:time] do
            puts ''
          end
        else
          @scheduler.cron cron_string do
            puts ''
          end
        end
      end
    end

    def clear
      @scheduler.jobs.each(&:unschedule)
    end
  end
end
