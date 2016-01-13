require 'spec_helper'

describe Goal do
  let(:partner) { create_partner }
  let(:mentee) { FactoryGirl.create(:mentee_full) }
  let(:mentor) { FactoryGirl.create(:mentor_full) }
  let(:match) { FactoryGirl.create(:match, mentors: [mentor], mentees: [mentee], organization: partnerorganization) }
  let(:goal) { FactoryGirl.create(:goal, match: match) }

  it { should validate_presence_of :title }
  it { should validate_presence_of :match }

  it 'should email mentor / mentee with new goal' do
    goal
    mail = ActionMailer::Base.deliveries
    mail[mail.length - 2].to.should eq [mentor.user.email]
    mail.last.to.should eq [mentee.user.email]
  end

  it 'should email partner when goal is completed' do
    goal.update(completed: true)
    mail = ActionMailer::Base.deliveries
    mail.last.to.should eq [partner.email]
  end

  it 'should email mentor when goal is verified' do
    goal.update(verified: true)
    mail = ActionMailer::Base.deliveries
    mail.last.to.should eq [mentor.user.email]
  end

  describe 'create' do
    it 'should create a new goal with title and verified and completed initialized to false' do
      goal_params = { :match_id => match.id, :title => 'title' }
      new_goal = Goal.create(goal_params)
      new_goal.completed.should eq false
    end
  end

  describe 'delete' do
    it 'should delete a goal' do
     new_goal = Goal.create(:match_id => match.id, :title => 'title')
     new_goal.delete
     Goal.all.length.should eq 0
    end
  end
end
