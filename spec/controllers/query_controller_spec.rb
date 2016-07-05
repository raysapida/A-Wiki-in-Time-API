require 'rails_helper'

RSpec.describe QueryController, :type => :controller do
  describe 'POST #create' do
    describe 'with polygon input empty' do
      let(:valid_params) { {
        radius: '300',
        lat: '33.280916241006025',
        long: '-84.42868699999997',
        type: 'battles',
        start_year: '1857',
        end_year: '1870'
      } }

      it 'should give a success status' do
        post :create, params: valid_params, xhr: true
        expect(response.status).to eq 200
      end

      it 'returns an empty array when theres no matching event' do
        post :create, params: valid_params, xhr: true
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['events']).to eq []
      end

      it 'returns an event within the given radius' do
        griswoldville = Event.create({
          title: 'Battle of Griswoldville',
          scraped_date: 1864,
          event_url: 'https://en.wikipedia.org/wiki/Battle_of_Griswoldville',
          qID: 'Q2888696',
          event_type: 'battle',
          latitude: 32.52030,
          longitude: -83.281013
        })


        post :create, params: valid_params, xhr: true
        parsed_response = JSON.parse(response.body)
        event = parsed_response['events'].first
        expect(event['qID']).to eq griswoldville.qID
      end
    end
  end

end
