class QueryController < ApplicationController
  LATITUDE_CONVERTER = 110.574
  LONGITUDE_CONVERTER = 111.320

  def create
    parameters = coerce_number_params(params)

    if params[:polygon] == 'true'
      @events = Event.polygon_query(parameters)
      render json: {events: @events, polygon: true}
    else
      updated_parameters = add_latlong_bounds(parameters)
      @events = Event.radius_query(updated_parameters)
      render json: {events: @events}
    end
  end


  private

  def coerce_number_params(params)
    {radius: params[:radius].to_i,
     lat: params[:lat].to_f,
     long: params[:long].to_f,
     type: params[:type],
     start_year: params[:start_year].to_i,
     end_year: params[:end_year].to_i}
  end

  def add_latlong_bounds(parameters = {})
    radians = parameters[:lat]/180*Math::PI
    lat_shift = parameters[:radius]/LATITUDE_CONVERTER
    long_shift = parameters[:radius]/(LONGITUDE_CONVERTER*Math.cos(radians))

    parameters.merge({
      lower_lat: (parameters[:lat] - lat_shift),
      upper_lat: (parameters[:lat] + lat_shift),
      lower_lng: (parameters[:long] - long_shift),
      upper_lng: (parameters[:long] + long_shift)
    })
  end
end
