module Illuminati
  class Schedule < Grape::API
    format :json
    namespace :schedules do
      desc "Returns all schedule events"
      get do
        Illuminati::Models::Schedule.all.desc(:number).as_json
      end
    end
  end
end
