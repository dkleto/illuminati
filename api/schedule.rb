module Illuminati
  class Schedule < Grape::API
    format :json
    file_opts = File::WRONLY | File::APPEND | File::CREAT
    @logger = Logger.new(File.open(ENV['illuminati.logpath'], file_opts))
    if ENV['RACK_ENV'] == 'production' then
      @logger.level = Logger::INFO
    else
      @logger.level = Logger::DEBUG
    end
    logger @logger

    helpers do
      def scheduler_sync
        scheduler = Illuminati::Scheduler.new(Rufus::Scheduler.singleton)
        scheduler.clear
        scheduler.sync
      end
      def logger
        API.logger
      end
    end

    namespace :schedules do
      desc "Returns all schedule events"
      get do
        Illuminati::Models::Schedule.all.desc(:number).as_json
      end
    end

    namespace :schedule do
      helpers do
        params :add_update do
          optional :repeat, type: Boolean
          given :repeat do
            cron_regexp = /^[0-9\/\*,-]+$/
            requires :cron_minute, type: String, regexp: cron_regexp
            requires :cron_hour, type: String, regexp: cron_regexp
            requires :cron_day, type: String, regexp: cron_regexp
            requires :cron_month, type: String, regexp: cron_regexp
            requires :cron_weekday, type: String, regexp: cron_regexp
          end
        end
      end

      desc "Returns schedule event by ID"
      params do
        requires '_id'
      end
      get ":_id" do
        schedule = Illuminati::Models::Schedule.find(params[:_id])
        error! "Not found", 404 unless schedule
        schedule.as_json
      end

      desc "Deletes a specific schedule event by ID"
      params do
        requires '_id'
      end
      delete ':_id' do
        schedule = Illuminati::Models::Schedule.find(params[:_id])
        error! "Not Found", 404 unless schedule
        schedule.destroy
        scheduler_sync
        schedule.as_json
      end

      desc "Creates a new schedule event"
      params do
        use :add_update
        optional :on, type: Boolean, default: true
        optional :bri, type: Integer, values: 0..255, default: 255
        optional :huesat, type: Hash do
          requires :hue, type: Integer, values: 0..65535
          requires :sat, type: Integer, values: 0..255
        end
        optional :xy, type: Hash do
          requires :x, type: Float, values: 0.0..1.0
          requires :y, type: Float, values: 0.0..1.0
        end
        exactly_one_of :huesat, :xy
        optional :alert, type: String, values: ['none', 'lselect'],
                 default: 'none'
        requires :time, type: DateTime, default: DateTime.now
        optional :transitiontime, type: Integer, values: 0..1800, default: 0
      end
      post do
        schedule = Hash.new
        declared(params, include_missing: false).each do |key, value|
          if !value.nil?
            schedule[key] = value
          end
        end
        new_schedule = Illuminati::Models::Schedule.create!(schedule)
        scheduler_sync
        new_schedule.as_json
      end

      desc "Updates a specific schedule event by ID"
      params do
        requires '_id'
        use :add_update
        optional :on, type: Boolean
        optional :bri, type: Integer, values: 0..255
        optional :hue, type: Integer, values: 0..65535
        optional :sat, type: Integer, values: 0..255
        optional :alert, type: String, values: ['none', 'lselect']
        optional :time, type: DateTime
        optional :transitiontime, type: Integer, values: 0..1800
      end
      put ':_id' do
        schedule = Illuminati::Models::Schedule.find(params[:_id])
        error! "Not Found", 404 unless schedule
        values = Hash.new
        declared_params = declared(params, include_missing: false)
        declared_params.each do |key, value|
          if !value.nil?
            values[key] = value
          end
        end
        schedule.update_attributes!(values)
        scheduler_sync
        schedule.as_json
      end

    end
  end
end
