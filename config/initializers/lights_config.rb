module Illuminati
  def load_lights(configpath, logger)
    hue = nil
    begin
      unless File.exists? configpath
        raise "Lights config file #{configpath} does " +
              "not exist or is not readable"
      end

      config = {}
      config = JSON.parse(IO.read(configpath))
      if config['bridge_ip'] and config['username'] then
        hue = Lights.new config["bridge_ip"], config["username"]
        logger.info "Lights config read from " +
                     configpath
      else
        raise "Could not read bridge_ip and username from lights " +
              " config file #{configpath}"
      end
    rescue Exception => e
      logger.error "Could not load lights configuration"
      logger.error e.message
    end
    hue
  end
  module_function :load_lights
end
