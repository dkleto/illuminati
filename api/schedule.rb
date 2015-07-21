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
        params do
          requires :command, type: String
          requires :time, type: DateTime, default: DateTime.now
          optional :transition_time, type: Integer, values: 0..1800, default: 0
          optional :repeat, type: Boolean, default: false
          cron_regexp = /^[0-9\/\*,-]+$/
          optional :cron_minute, type: String, regexp: cron_regexp
          optional :cron_hour, type: String, regexp: cron_regexp
          optional :cron_day, type: String, regexp: cron_regexp
          optional :cron_month, type: String, regexp: cron_regexp
          optional :cron_weekday, type: String, regexp: cron_regexp
          all_or_none_of :cron_minute, :cron_hour, :cron_day, :cron_month,
              :cron_weekday
        end
      post do
        schedule = Hash.new
        declared(params).each do |key, value|
          schedule[key] = value
        end
        new_schedule = Illuminati::Models::Schedule.create!(schedule)
        new_schedule.as_json
      end

      desc "Update a specific schedule event by ID"
        params do
          requires '_id'
          optional :command, type: String
          optional :time, type: DateTime, default: DateTime.now
          optional :transition_time, type: Integer, values: 0..1800, default: 0
          optional :repeat, type: Boolean, default: false
          cron_regexp = /^[0-9\/\*,-]+$/
          optional :cron_minute, type: String, regexp: cron_regexp
          optional :cron_hour, type: String, regexp: cron_regexp
          optional :cron_day, type: String, regexp: cron_regexp
          optional :cron_month, type: String, regexp: cron_regexp
          optional :cron_weekday, type: String, regexp: cron_regexp
          all_or_none_of :cron_minute, :cron_hour, :cron_day, :cron_month,
              :cron_weekday
        end
      put ':_id' do
        schedule = Illuminati::Models::Schedule.find(params[:_id])
        error! "Not Found", 404 unless schedule
        values = Hash.new
        declared(params).each do |key, value|
          values[key] = value
        end
        schedule.update_attributes!(values)
        schedule.as_json
      end

      desc "Delete a specific schedule event by ID"
      delete ':_id' do
        params do
          requires '_id'
        end
        schedule = Illuminati::Models::Schedule.find(params[:_id])
        error! "Not Found", 404 unless schedule
        schedule.destroy
        schedule.as_json
      end
    end
  end
end
