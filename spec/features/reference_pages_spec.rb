require 'spec_helper'

feature 'Reference Pages' do
	let(:reference) { FactoryGirl.create(:reference) }

  scenario 'a reference must have a url_token to view an endorsement form' do
    visit references_path
    page.should have_content('Please use the link provided in your email.')
  end

  scenario 'a reference visits endorsement form using provided link' do
    visit "/references/#{reference.url_token}"
    page.should have_content(reference.mentor.user.name)
    page.should have_content('Please fill out the following endorsement:')
  end

  feature 'Endorsement Form' do
    before do
      visit "/references/#{reference.url_token}"
      fill_in 'reference_describe_duties', with: "Does duties"
      fill_in 'reference_acquainted', with: "11 years"
      select 'Yes', from: 'reference_reliable'
      select 'Yes', from: 'reference_follow_through'
      fill_in 'reference_uncomfortable_groups', with: "Some Answer"
      fill_in 'reference_strengths', with: "Some Answer"
      fill_in 'reference_improvement_areas', with: "Some Answer"
      fill_in 'reference_content', with: "Some Answer"
      click_button 'Submit'
    end

    scenario 'a reference follows the email link to fill out an endorsement' do
      page.should have_content('Thank you!!')
    end

    scenario 'a reference follows a link again and is denied access to the endorsement page' do
      visit "/references/#{reference.url_token}"
      page.should have_content('You have already written an endorsement. Thank you!')
    end
  end
end
