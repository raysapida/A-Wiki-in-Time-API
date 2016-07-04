class Event < ApplicationRecord
  # belongs_to :query
  # has_many :queries, through: :queries_events
  # has_many :queries_events
  validates_presence_of :qID, :latitude, :longitude, :event_type
end
