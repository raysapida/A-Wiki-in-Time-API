class QueryController < ApplicationController
  LATITUDE_CONVERTER = 110.574
  LONGITUDE_CONVERTER = 111.320

  def create
    radius, lat, long, type, start_year, end_year = destructure_params(params)
    lower_lat, upper_lat, lower_lng, upper_lng = destructure_latlong_bounds(lat, long, radius)

    if params[:polygon] == 'true'
      @events = Event.polygon_query(type, start_year, end_year)
      render json: {events: @events, polygon: true}
    else
      @events = Event.radius_query(type, lower_lat, upper_lat, lower_lng, upper_lng, start_year, end_year)
      render json: {events: @events}
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
