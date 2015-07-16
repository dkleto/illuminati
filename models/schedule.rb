module Illuminati
  module Models
    class Schedule
      include Mongoid::Document

      field :test, type: String
    end
  end
end
