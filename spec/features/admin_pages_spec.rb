require 'spec_helper'

feature 'Admin Pages' do
  let(:admin) { create_admin }

  scenario 'allow admins to sign in' do
    login(admin)
    page.should have_content("Admin")
  end

  scenario "allow adding of an organization" do
    login(admin)
    click_link 'Organizations'
    click_link 'New Organization'
    fill_in 'Name',  with: "New Organization"
    select("Partner",:from=> "Type")
    fill_in 'Phone number', with: "503.555.5555"
    fill_in 'Address1', with: "4 Privet Drive"
    fill_in 'Address2', with: "Cupboard under the stairs"
    fill_in 'City', with: "Little Whinging"
    fill_in 'State', with: "OR"
    fill_in 'Zip code', with: "97208"
    fill_in 'About us', with: "This is the about us text"

    click_button 'Create Organization'
    o = Organization.last
    uri = URI.parse(current_url)
    "#{uri.path}".should eq "/admin/organizations/#{o.id}"
    page.should have_content("Organization Details")
    page.should have_content("New Organization")
    page.should have_content("Cupboard under the stairs")
  end
end
