require 'spec_helper'

feature 'Mentee Pages' do
  let(:partner_org) { FactoryGirl.create(:partner_organization) }
  let(:mentee_user) { FactoryGirl.create(:mentee_user, org_id: partner_org.id) }

  context 'when umbrella organization' do
    scenario 'mentee will see application after first login' do
      login(mentee_user)
      page.should have_content('Step 1: Tell us more about you')
      page.should_not have_content('Full Application')
    end

    scenario 'mentee will see profile page after completing application' do
      mentee_partial = FactoryGirl.create(:mentee)
      login(mentee_partial.user)
      page.should have_content(mentee_partial.user.name)
    end
  end

  context 'when partner organization' do
    scenario 'mentee will see the full application after logging in' do
      login(mentee_user)
      page.should have_css('div#profile')
    end

    scenario 'mentee will see a full profile page after a full application is completed' do
      mentee_full = FactoryGirl.create(:mentee_full, user: mentee_user)
      login(mentee_user)
      page.should have_content(mentee_full.user.name)
      page.should have_content("What is your child's ethnicity?")
    end
  end
end
