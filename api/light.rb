module Illuminati
  class Light < Grape::API
    format :json
    rescue_from Grape::Exceptions::ValidationErrors do |e|
      error! e, 400
    end

    helpers do
      def get_lights
        lightsconfig = ENV['illuminati.lightsconfigpath']
        @hue ||= Illuminati.load_lights(lightsconfig, logger)
      end
      def logger
        API.logger
      end
    end

    namespace :lights do
      desc "Updates all lights at once"

      params do
        optional :xy, type: Hash do
          requires :x, type: Float, values: 0.0..1.0
          requires :y, type: Float, values: 0.0..1.0
        end
        optional :on, type: Boolean
        optional :bri, type: Integer, values: 0..255
        optional :alert, type: String, values: ['none', 'lselect']
        optional :transitiontime, type: Integer, values: 0..1800, default: 0
        at_least_one_of :xy, :on, :bri, :alert, :transitiontime
      end
      put :all do
        get_lights
        values = Hash.new
        declared_params = declared(params, include_missing: false)
        declared_params.each do |key, value|
          if !value.nil?
            if key == 'xy'
              values['xy'] = [value['x'], value['y']]
            else
              values[key] = value
            end
          end
        end
        if @hue.nil? then
          logger.info "No lights object available"
          nil
        else
          b = BulbState.new(values)
          begin
            response = @hue.set_group_state(0,b)
            response.as_json
          rescue StandardError => e
            logger.error "Error contacting the Hue API: " + e.message
            error!({error: 'hueContactErr', detail: 'Error contacting the Hue API'}, 500)
          end
        end
      end

    end
  end
end
