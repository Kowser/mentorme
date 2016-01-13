require 'spec_helper'

describe Rating do
  let(:mentee) { FactoryGirl.build(:mentee) }
  let(:mentor) { FactoryGirl.build(:mentor) }

  context 'when mentor creates a check in and includes a rating' do
    it 'should create a Rating' do
      FactoryGirl.create(:check_in, mentors: [mentor], mentees: [mentee], ratings: [Rating.create(notes: "note", rating: 3)])
      expect(Rating.all.count).should eq 1
    end
  end
end
