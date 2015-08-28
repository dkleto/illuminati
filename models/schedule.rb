module Illuminati
  module Models
    class Schedule
      include Mongoid::Document

      field :on, type: Boolean
      field :bri, type: Integer
      field :huesat, type: Hash
      field :alert, type: String
      field :xy, type: Hash
      field :transitiontime, type: Integer
      field :time, type: DateTime
      field :repeat, type: Boolean
      field :cron, type: Hash
    end
  end
end
