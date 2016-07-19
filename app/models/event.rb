class Event < ApplicationRecord
  # belongs_to :query
  # has_many :queries, through: :queries_events
  # has_many :queries_events
  validates_presence_of :qID, :latitude, :longitude, :event_type
  validates_uniqueness_of :qID

  scope :battles_and_sieges, ->(start, finish) {
    where(event_type: ['battle', 'siege']).where(scraped_date: start..finish) 
  }
  scope :archaeological_sites, -> { where(event_type: 'archaeological site')  }
  scope :explorers, -> { where(event_type: 'explorer') }
  scope :natural_disasters, ->(start, finish) {
    where(event_type: ['earthquake', 'volcano', 'tornado'])
    .where(point_in_time: DateTime.new(start)..DateTime.new(finish))
  }
  scope :assasinations, -> { where(event_type: 'assassination')  }

  def self.radius_query(type:, lower_lat:, upper_lat:, lower_lng:, upper_lng:, start_year:, end_year:,  **_)
    case type
    when 'battles'
      Event.battles_and_sieges(start_year, end_year).where(latitude: lower_lat..upper_lat).where(longitude: lower_lng..upper_lng)
    when 'archaeological_sites'
      Event.archaeological_sites.where(latitude: lower_lat..upper_lat).where(longitude: lower_lng..upper_lng)
    when 'assassinations'
      Event.assassinations.where(latitude: lower_lat..upper_lat).where(longitude: lower_lng..upper_lng)
    when 'natural_disasters'
      Event.natural_disasters(start_year, end_year).where(latitude: lower_lat..upper_lat).where(longitude: lower_lng..upper_lng)
    when 'explorers'
      Event.explorers.where(latitude: lower_lat..upper_lat).where(longitude: lower_lng..upper_lng)
    else
      @events = Event.where(latitude: lower_lat..upper_lat).where(longitude: lower_lng..upper_lng)
    end
  end

  def self.polygon_query(type:, start_year:, end_year:,  **_)
      case type
      when 'battles'
        Event.battles_and_sieges(start_year, end_year).where.not(latitude: nil)
      when 'archaeological_sites'
        Event.archaeological_sites.where.not(latitude: nil);
      when 'explorers'
        Event.explorers.where.not(latitude: nil)
      when 'natural_disasters'
        Event.natural_disasters(start_year, end_year).where.not(latitude: nil)
      when 'assassinations'
        Event.assassinations.where.not(latitude: nil)
      else
        all_of_the_above = Event.battles_and_sieges(start_year, end_year).where.not(latitude: nil)
        all_of_the_above += Event.archaeological_sites.where.not(latitude: nil);
        all_of_the_above += Event.explorers.where.not(latitude: nil)
        all_of_the_above += Event.natural_disasters(start_year, end_year).where.not(latitude: nil)
        all_of_the_above += Event.assassinations.where.not(latitude: nil)
      end
  end
end
