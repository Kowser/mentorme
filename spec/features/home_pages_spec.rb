require 'spec_helper'

feature 'Home Pages' do
  scenario "visitors to the homepage see a hero image" do
    # spec_helper creates one seed organization "MentorMe, Inc."
    visit ''
    page.should have_content("MentorMe is a unique, cloud-based platform built for mentoring programs by people who mentor")
  end

  scenario "visitor signs up as mentor" do
    visit ''
    fill_in 'user_name', with: "Inigo Montoya"
    fill_in 'user_email', with: 'Inigo@princessbride.com'
    fill_in 'user_password', with: 'myfather'
    fill_in 'user_password_confirmation', with: 'myfather'
    select 'Mentor', from: 'user_as_a'
    click_button 'Sign Up'
    page.should have_content('A message with a confirmation link has been sent to your email address. Please open the link to activate your account.')
  end

  scenario "visitor signs up as mentee" do
    visit ''
    fill_in 'user_name', with: "Inigo Montoya"
    fill_in 'user_email', with: 'Inigo@princessbride.com'
    fill_in 'user_password', with: 'myfather'
    fill_in 'user_password_confirmation', with: 'myfather'
    select 'Mentee', from: 'user_as_a'
    click_button 'Sign Up'
    page.should have_content('A message with a confirmation link has been sent to your email address. Please open the link to activate your account.')
  end
end
