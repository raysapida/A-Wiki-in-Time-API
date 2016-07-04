class QueryController < ApplicationController
  LATITUDE_CONVERTER = 110.574
  LONGITUDE_CONVERTER = 111.320

  def create
    radius, lat, long, type, start_year, end_year = destructure_params(params)
    lower_lat, upper_lat, lower_lng, upper_lng = destructure_latlong_bounds(lat, long, radius)

    if params[:polygon] == 'true'
      case type
      when 'battles'
        @events = Event.where(scraped_date: start_year..end_year).where.not(latitude: nil).where(event_type: ['battle', 'siege']);
      when 'archaeological_sites'
        @events = Event.where.not(latitude: nil).where(event_type: 'archaeological site');
      when 'explorers'
        @events = Event.where.not(latitude: nil).where(event_type: 'explorer');
      when 'natural_disasters'
        @events = Event.where.not(latitude: nil).where(point_in_time: DateTime.new(start_year)..DateTime.new(end_year)).where(event_type: ['earthquake', 'volcano', 'tornado']);
      when 'assassinations'
        @events = Event.where.not(latitude: nil).where(event_type: 'assassination');
      else
        @events = Event.where(scraped_date: start_year..end_year).where.not(latitude: nil).where(event_type: ['battle', 'siege']);
        @events += Event.where.not(latitude: nil).where(event_type: 'archaeological site');
        @events += Event.where.not(latitude: nil).where(event_type: 'explorer');
        @events += Event.where.not(latitude: nil).where(point_in_time: DateTime.new(start_year)..DateTime.new(end_year)).where(event_type: ['earthquake', 'volcano', 'tornado']);
        @events += Event.where.not(latitude: nil).where(event_type: 'assassination');

      end

      if @events
        # @events.each do |event|
        #     @queries_event = QueriesEvent.create(query_id: @query.id, event_id: event.id)
        # end
        response = {events: @events, polygon: true}
      else
        response = {error: "No events found"}
      end
      render json: response
    else

      # @query = Query.create(latitude: lat, longitude: long, radius: radius, start_date: start_year, end_date: end_year, event_type: type)

      if type == 'battles'
        @events = Event.where(scraped_date: start_year..end_year).where(latitude: lower_lat..upper_lat).where(longitude: lower_lng..upper_lng).where(event_type: ['battle', 'siege'])
      elsif type == 'archaeological_sites'
        @events = Event.where(latitude: lower_lat..upper_lat).where(longitude: lower_lng..upper_lng).where(event_type: 'archaeological site')
      elsif type == 'assassinations'
        @events = Event.where(latitude: lower_lat..upper_lat).where(longitude: lower_lng..upper_lng).where(event_type: 'assassination')
      elsif type == 'natural_disasters'
        @events = Event.where(point_in_time: DateTime.new(start_year)..DateTime.new(end_year)).where(latitude: lower_lat..upper_lat).where(longitude: lower_lng..upper_lng).where(event_type: ['earthquake', 'volcano', 'tornado'])
      elsif type == 'explorers'
        @events = Event.where(latitude: lower_lat..upper_lat).where(longitude: lower_lng..upper_lng).where(event_type: 'explorer')
      else
        @events = Event.where(latitude: lower_lat..upper_lat).where(longitude: lower_lng..upper_lng)
      end

      if @events
        # @events.each do |event|
        #     @queries_event = QueriesEvent.create(query_id: @query.id, event_id: event.id)
        # end
        response = {events: @events}
      else
        response = {error: "No events found"}
      end
      render json: response
    end
  end


  private

  def destructure_params(params)
    [params[:radius].to_i, params[:lat].to_f,
     params[:long].to_f, params[:type],
     params[:start_year].to_i, params[:end_year].to_i]
  end

  def destructure_latlong_bounds(lat, long, radius)
    radians = lat/180*Math::PI
    lat_shift = radius/LATITUDE_CONVERTER
    long_shift = radius/(LONGITUDE_CONVERTER*Math.cos(radians))

    [ (lat - lat_shift), (lat + lat_shift),
      (long - long_shift), (long + long_shift)]
  end
end
