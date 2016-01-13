require 'spec_helper'

describe Match do
  let(:mentee) { FactoryGirl.create(:mentee_full) }
  let(:mentor) { FactoryGirl.create(:mentor_full) }
  let(:match) { FactoryGirl.build(:match, mentors: [mentor], mentees: [mentee]) }

  it 'should be valid' do
    match.valid?.should be_true
  end

  it 'should email mentor & mentee when matched' do
    match.save
    email = ActionMailer::Base.deliveries
    email[email.length - 2].to.should eq [mentor.user.email]
    email.last.to.should eq [mentee.user.email]
  end

  it 'should only return active matches by default' do
    FactoryGirl.create_list(:match, 5)
    Match.last.update(active: false)
    Match.count.should eq 4
  end

  it 'should return all matches when unscoped' do
    FactoryGirl.create_list(:match, 5)
    Match.last.update(active: false)
    Match.unscoped.count.should eq 5
  end

end
