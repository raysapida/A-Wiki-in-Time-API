require 'rails_helper'

RSpec.describe QueryController, :type => :controller do
  describe 'POST #create' do
    describe 'with radius query' do
      let(:battle_params) { {
        radius: '300',
        lat: '33.280916241006025',
        long: '-84.42868699999997',
        type: 'battles',
        start_year: '1857',
        end_year: '1870'
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
        params = {
          radius: '300',
          lat: '37.819302695136',
          long: '-122.19968309374997',
          type: 'natural_disasters',
          start_year: '1900',
          end_year: '1920'
        }

        sf_earthquake = Event.create({
          title: '1906 San Francisco earthquake',
          event_url: 'https://en.wikipedia.org/wiki/1906_San_Francisco_earthquake',
          qID: 'Q211386',
          event_type: 'earthquake',
          point_in_time: DateTime.new(1906),
          latitude: 37.75,
          longitude: -122.55
        })

        post :create, params: params, xhr: true

        parsed_response = JSON.parse(response.body)
        event = parsed_response['events'].first
        expect(event['qID']).to eq sf_earthquake.qID
      end

      it 'returns an archaeological site  within the given radius' do
        params = {
          radius: '300',
          lat: '37.819302695136',
          long: '-122.19968309374997',
          type: 'archaeological_sites'
        }

        emeryville = Event.create({
          title: 'Emeryville Shellmound',
          event_url: 'https://en.wikipedia.org/wiki/Emeryville_Shellmound',
          qID: 'Q211386',
          event_type: 'archaeological site',
          latitude: 37.834,
          longitude: -122.29263
        })

        post :create, params: params, xhr: true

        parsed_response = JSON.parse(response.body)
        event = parsed_response['events'].first
        expect(event['qID']).to eq emeryville.qID
      end

      it 'returns an explorer within the given radius' do
        params = {
          radius: '300',
          lat: '37.819302695136',
          long: '-122.19968309374997',
          type: 'explorers'
        }

        robert = Event.create({
          title: 'Robert S. Williamson',
          event_url: 'https://en.wikipedia.org/wiki/Robert_S._Williamson',
          qID: 'Q7349523',
          event_type: 'explorer',
          latitude: 37.778067677511686,
          longitude: -122.41803636523434
        })

        post :create, params: params, xhr: true

        parsed_response = JSON.parse(response.body)
        event = parsed_response['events'].first
        expect(event['qID']).to eq robert.qID
      end

      it 'returns a murder case within the given radius' do
        params = {
          radius: '400',
          lat: '37.819302695136',
          long: '-122.19968309374997',
          type: 'assasinations'
        }

        larry = Event.create({
          title: 'Murder of Larry McNabney',
          event_url: 'https://en.wikipedia.org/wiki/Murder_of_Larry_McNabney',
          qID: 'Q6937950',
          event_type: 'assasinations',
          latitude: 38.59623778636446,
          longitude: -121.49655809374997
        })

        post :create, params: params, xhr: true

        parsed_response = JSON.parse(response.body)
        event = parsed_response['events'].first
        expect(event['qID']).to eq larry.qID
      end

      it 'returns all types of events within the raidus and time span' do
        params = {
          radius: '400',
          lat: '37.819302695136',
          long: '-122.19968309374997',
          start_year: '1900',
          end_year: '1920'
        }

        sf_earthquake = Event.create({
          title: '1906 San Francisco earthquake',
          event_url: 'https://en.wikipedia.org/wiki/1906_San_Francisco_earthquake',
          qID: 'Q211386',
          event_type: 'earthquake',
          point_in_time: DateTime.new(1906),
          latitude: 37.75,
          longitude: -122.55
        })

        larry = Event.create({
          title: 'Murder of Larry McNabney',
          event_url: 'https://en.wikipedia.org/wiki/Murder_of_Larry_McNabney',
          qID: 'Q6937950',
          event_type: 'assasinations',
          latitude: 38.59623778636446,
          longitude: -121.49655809374997
        })

        robert = Event.create({
          title: 'Robert S. Williamson',
          event_url: 'https://en.wikipedia.org/wiki/Robert_S._Williamson',
          qID: 'Q7349523',
          event_type: 'explorer',
          latitude: 37.778067677511686,
          longitude: -122.41803636523434
        })

        post :create, params: params, xhr: true

        parsed_response = JSON.parse(response.body)
        events = parsed_response['events']
        qIDs = events.map{|event| event['qID']}
        expect(qIDs).to include sf_earthquake.qID
        expect(qIDs).to include larry.qID
        expect(qIDs).to include robert.qID
      end

      it 'excludes events not within the raidus and time span' do
        params = {
          radius: '400',
          lat: '37.819302695136',
          long: '-122.19968309374997',
          start_year: '1900',
          end_year: '1920'
        }

        Event.create({
          title: '1906 San Francisco earthquake',
          event_url: 'https://en.wikipedia.org/wiki/1906_San_Francisco_earthquake',
          qID: 'Q211386',
          event_type: 'earthquake',
          point_in_time: DateTime.new(1906),
          latitude: 37.75,
          longitude: -122.55
        })


        griswoldville = Event.create({
          title: 'Battle of Griswoldville',
          scraped_date: 1864,
          event_url: 'https://en.wikipedia.org/wiki/Battle_of_Griswoldville',
          qID: 'Q2888696',
          event_type: 'battle',
          latitude: 32.52030,
          longitude: -83.281013
        })

        post :create, params: params, xhr: true

        parsed_response = JSON.parse(response.body)
        events = parsed_response['events']
        qIDs = events.map{|event| event['qID']}
        expect(qIDs).not_to include griswoldville.qID
      end
    end
  end

end
