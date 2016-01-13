require 'spec_helper'

describe Mentee do
  let(:mentee_partial) { FactoryGirl.build(:mentee) }

  it 'should validate at least one phone number is present' do
    mentee_partial.update(guardian_cell_phone: nil)
    mentee_partial.step = "2"
    mentee_partial.valid?.should be_false
  end

  it 'should return preferred phone number' do
    mentee_partial.guardian_cell_phone = "555-555-1234"
    mentee_partial.guardian_phone_preference = "Cell"
    mentee_partial.preferred_phone.should eq "555-555-1234"
  end

  context 'when umbrella organization' do
    it 'should be valid' do
      mentee_partial.valid?.should be_true
    end
  end

  context 'when partner organization mentee profile' do
    it 'should be valid' do
      mentee_full = FactoryGirl.build(:mentee_full)
      mentee_full.valid?.should be_true
    end
  end
end
