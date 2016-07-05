require 'rails_helper'

RSpec.describe QueryController, :type => :controller do
  describe 'POST #create' do
    describe 'with polygon input empty' do
      let(:battle_params) { {
        radius: '300',
        lat: '33.280916241006025',
        long: '-84.42868699999997',
        type: 'battles',
        start_year: '1857',
        end_year: '1870'
      } }

      let(:disaster_params) { {
        radius: '300',
        lat: '37.819302695136',
        long: '-122.19968309374997',
        type: 'natural_disasters',
        start_year: '1900',
        end_year: '1920'
      } }

      it 'should give a success status' do
        post :create, params: battle_params, xhr: true
        expect(response.status).to eq 200
      end

      it 'returns an empty array when theres no matching event' do
        post :create, params: battle_params, xhr: true
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['events']).to eq []
      end

      it 'returns a battle within the given radius' do
        griswoldville = Event.create({
          title: 'Battle of Griswoldville',
          scraped_date: 1864,
          event_url: 'https://en.wikipedia.org/wiki/Battle_of_Griswoldville',
          qID: 'Q2888696',
          event_type: 'battle',
          latitude: 32.52030,
          longitude: -83.281013
        })


        post :create, params: battle_params, xhr: true
        parsed_response = JSON.parse(response.body)
        event = parsed_response['events'].first
        expect(event['qID']).to eq griswoldville.qID
      end

      it 'returns a disaster  within the given radius' do
        sf_earthquake = Event.create({
          title: '1906 San Francisco earthquake',
          event_url: 'https://en.wikipedia.org/wiki/1906_San_Francisco_earthquake',
          qID: 'Q211386',
          event_type: 'earthquake',
          point_in_time: DateTime.new(1906),
          latitude: 37.75,
          longitude: -122.55,
        })

        post :create, params: disaster_params, xhr: true
        parsed_response = JSON.parse(response.body)
        event = parsed_response['events'].first
        expect(event['qID']).to eq sf_earthquake.qID
      end
    end
  end

end
