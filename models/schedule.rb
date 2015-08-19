module Illuminati
  module Models
    class Schedule
      include Mongoid::Document

      field :on, type: Boolean
      field :bri, type: Integer
      field :hue, type: Integer
      field :sat, type: Integer
      field :alert, type: String
      field :xy, type: Array
      field :transitiontime, type: Integer
      field :time, type: DateTime
      field :repeat, type: Boolean
      field :cron_minute, type: String
      field :cron_hour, type: String
      field :cron_day, type: String
      field :cron_month, type: String
      field :cron_weekday, type: String
    end
  end
end
