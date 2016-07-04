class Event < ApplicationRecord
  # belongs_to :query
  # has_many :queries, through: :queries_events
  # has_many :queries_events
  validates_presence_of :qID, :latitude, :longitude, :event_type
  scope :battles_and_sieges, ->(start, finish) {
    where(event_type: ['battle', 'siege']).where(scraped_date: start..finish) 
  }
  scope :archaeological_sites, -> { where(event_type: 'archaeological_sites')  }
  scope :explorers, -> { where(event_type: 'explorer') }
  scope :natural_disasters, ->(start, finish) {
    where(event_type: ['earthquake', 'volcano', 'tornado'])
    .where(point_in_time: DateTime.new(start)..DateTime.new(finish))
  }
end
