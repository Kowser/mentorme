require 'spec_helper'

feature 'Mentor Pages' do
  context 'When organization is an umbrella' do
    scenario 'mentor will see the application after first login' do
      mentor_user = FactoryGirl.create(:mentor_user)
      mentor_user.confirmed_at = Time.now

      login(mentor_user)
      page.should have_content('Step 1: Tell us more about you')
    end

    scenario 'mentor will see a profile page after an application is completed' do
      mentor_partial = FactoryGirl.create(:mentor)

      login(mentor_partial.user)
      page.should have_content(mentor_partial.user.name)
    end
  end

  context 'When organization is a partner' do
	  scenario 'mentor can submit references' do
      partner_org = FactoryGirl.create(:partner_organization)
      mentor_user = FactoryGirl.create(:mentor_user, org_id: partner_org.id)
      mentor_profile = FactoryGirl.create(:mentor, user: mentor_user)
	    login(mentor_user)
    	page.should have_content('We require 3 references')
    end

    scenario "mentor will see full profile after submitting full application" do
      mentor_profile = FactoryGirl.create(:mentor)
  		3.times do
  			mentor_profile.references << FactoryGirl.build(:reference, mentor: @mentor)
  		end

      login (mentor_profile.user)
    	page.should have_content("References")
  	end

    scenario "partner can upload file for a mentor" do
      partner = create_partner
      mentor_user = FactoryGirl.create(:mentor_user, org_id: partnerorganization.id)
      mentor_profile = FactoryGirl.create(:mentor, user: mentor_user)
      login(partner)
      click_link "Mentors"
      click_link mentor_profile.user.name
      click_link "Edit Mentor"
      attach_file  "Document", File.expand_path("./public/files/mentor_import.csv")
      click_button "Update Profile"
      expect(page).to have_content "mentor_import.csv"
    end

    scenario "partner can delete mentor profile documents" do
      partner = create_partner
      mentor_user = FactoryGirl.create(:mentor_user, org_id: partnerorganization.id)
      mentor_profile = FactoryGirl.create(:mentor, user: mentor_user)
      login(partner)
      click_link "Mentors"
      click_link mentor_profile.user.name
      click_link "Edit Mentor"
      attach_file "Document", File.expand_path("./public/files/mentor_import.csv")
      click_button "Update Profile"
      expect(page).to have_content "mentor_import.csv"
      click_link "Delete"
      expect(page).not_to have_content "mentor_import.csv"
    end
	end
end
