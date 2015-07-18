module Illuminati
  class Schedule < Grape::API
    format :json
    namespace :schedules do
      desc "Returns all schedule events"
      get do
        Illuminati::Models::Schedule.all.desc(:number).as_json
      end
    end

    namespace :schedule do
      desc "Returns schedule event by ID"
      get ":_id" do
        schedule = Illuminati::Models::Schedule.find(params[:_id])
        error! "Not found", 404 unless schedule
        schedule.as_json
      end

      desc "Creates a new schedule event"
      post do
        params do
          requires :command, type: String
          requires :time, type: Datetime, default: Time.now
          optional :transition_time, type: Integer, values: 0..1800, default: 0
          optional :repeat, type: Boolean, default: false
          given :repeat do
            cron_regexp = /^[0-9\/\*]+$/
            optional :cron_minute, type: String, regexp: cron_regexp
            optional :cron_hour, type: String, regexp: cron_regexp
            optional :cron_day, type: String, regexp: cron_regexp
            optional :cron_month, type: String, regexp: cron_regexp
            optional :cron_weekday, type: String, regexp: cron_regexp
            all_or_none_of :cron_minute, :cron_hour, :cron_day, :cron_month,
              :cron_weekday
          end
        end
        schedule = Illuminati::Models::Schedule.create!(declared(params))
        schedule.as_json
      end
    end
  end
end
