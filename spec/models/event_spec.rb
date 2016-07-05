require 'rails_helper'

RSpec.describe Event, :type => :model do
  it { should validate_presence_of :qID }
  it { should validate_presence_of :latitude }
  it { should validate_presence_of :longitude }
  it { should validate_presence_of :event_type }
end
