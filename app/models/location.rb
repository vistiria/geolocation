module Geolocation
  module Models
    class Location
      include Mongoid::Document

      field :ip, :type => String
      field :host, :type => String
      field :latitude, :type => Float
      field :longitude, :type => Float

      validates :ip, presence: true
      validates :latitude, presence: true
      validates :longitude, presence: true
    end
  end
end
