module Illuminati
  def logger(logpath, env)
    file_opts = File::WRONLY | File::APPEND | File::CREAT
    if env == 'production' then
      output = File.open(logpath, file_opts)
      level = Logger::INFO
    elsif env == 'development' then
      output = File.open(logpath, file_opts)
      level = Logger::DEBUG
    else
      output = STDOUT
      level = Logger::DEBUG
    end

    output.sync = true
    logger = Logger.new(output)
    logger.level = level

    logger
  end
  module_function :logger
end
