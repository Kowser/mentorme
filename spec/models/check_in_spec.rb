require 'spec_helper'

describe CheckIn do
  let(:mentee) { FactoryGirl.build(:mentee) }
  let(:mentor) { FactoryGirl.build(:mentor) }
  let(:check_in) { FactoryGirl.create(:check_in, mentors: [mentor], mentees: [mentee]) }

  context 'when mentor checks in' do
    it 'should be valid' do
      check_in.valid?.should be_true
    end
  end

  context 'when mentee checks in' do
    it 'should be valid' do
      check_in.ratings[0].update(rating: 4, notes: "good meeting")
      check_in.valid?.should be_true
    end
  end
end
