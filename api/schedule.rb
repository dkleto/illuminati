module Illuminati
  class Schedule < Grape::API
    format :json
    rescue_from Grape::Exceptions::ValidationErrors do |e|
      error! e, 400
    end

    logger $logger

    helpers do
      def scheduler_sync
        lightsconfig = ENV['illuminati.lightsconfigpath']
        @hue ||= Illuminati.load_lights(lightsconfig, logger)
        scheduler = Illuminati::Scheduler.new(Rufus::Scheduler.singleton, @hue)
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
        params :cron_params do
          cron_regexp = /^[0-9\/\*,-]+$/
          optional :cron, type: Hash do
            requires :minute, type: String, regexp: cron_regexp
            requires :hour, type: String, regexp: cron_regexp
            requires :day, type: String, regexp: cron_regexp
            requires :month, type: String, regexp: cron_regexp
            requires :weekday, type: String, regexp: cron_regexp
          end
        end
        params :colours do
          optional :huesat, type: Hash do
            requires :hue, type: Integer, values: 0..65535
            requires :sat, type: Integer, values: 0..255
          end
          optional :xy, type: Hash do
            requires :x, type: Float, values: 0.0..1.0
            requires :y, type: Float, values: 0.0..1.0
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
        use :cron_params
        optional :on, type: Boolean, default: true
        optional :bri, type: Integer, values: 0..255, default: 255
        use :colours
        exactly_one_of :huesat, :xy
        optional :alert, type: String, values: ['none', 'lselect'],
                 default: 'none'
        requires :time, type: DateTime, default: DateTime.now
        optional :transitiontime, type: Integer, values: 0..1800, default: 0
        optional :label, type: String
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
        optional :clear_cron
        use :cron_params
        mutually_exclusive :clear_cron, :cron
        optional :on, type: Boolean
        optional :bri, type: Integer, values: 0..255
        use :colours
        mutually_exclusive :huesat, :xy
        optional :alert, type: String, values: ['none', 'lselect']
        optional :time, type: DateTime
        optional :transitiontime, type: Integer, values: 0..1800
        optional :label, type: String
      end
      put ':_id' do
        schedule = Illuminati::Models::Schedule.find(params[:_id])
        error! "Not Found", 404 unless schedule
        values = Hash.new
        declared_params = declared(params, include_missing: false)
        declared_params.each do |key, value|
          if !value.nil?
            values[key] = value
            case key
              when 'huesat'
                values['xy'] = nil
              when 'xy'
                values['huesat'] = nil
              when 'clear_cron'
                values['cron'] = nil
                values.delete('clear_cron')
            end
          end
        end
        schedule.update_attributes!(values)
        scheduler_sync
        schedule.as_json
      end

    end
  end
end
