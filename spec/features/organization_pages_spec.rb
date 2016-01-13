require 'spec_helper'

feature 'Organization Pages' do
  let(:partner) { create_partner }

  context "when a partner organization" do

    feature "mentor index" do
      it "shows all registered mentor users" do
        FactoryGirl.create_list(:mentor_user, 5, org_id: partnerorganization.id)
        login(partner)
        click_link "Mentors"
        page.should have_content("Total: 5")
      end

      it 'links to individual mentor profile(s)' do
        mentor_user = FactoryGirl.create(:mentor_user, org_id: partnerorganization.id)
        mentor_profile = FactoryGirl.create(:mentor, birth_date: '11/19/1979',user: mentor_user)

        login(partner)
        click_link "Mentors"
        click_link mentor_user.name
        page.should have_content('11/19/1979')
      end
    end

    feature "Mentee Index" do
      it "shows all registered mentee users" do
        FactoryGirl.create(:mentee_role)
        FactoryGirl.create_list(:mentee_user, 3, org_id: partnerorganization.id)

        login(partner)
        click_link "Mentees"
        page.should have_content("Total: 3")
      end

      it 'shows an individual mentee profile' do
        FactoryGirl.create(:mentee_role)
        mentee_user = FactoryGirl.create(:mentee_user, org_id: partnerorganization.id)
        mentee_profile = FactoryGirl.create(:mentee, birth_date: '11/19/1999', user: mentee_user)

        login(partner)
        click_link "Mentees"
        click_link(mentee_profile.user.name)
        page.should have_content('11/19/1999')
      end
    end

    feature "Import Users" do
      # scenario "partner can imports mentors" do
      #   partner = create_partner
      #   login(partner)
      #   click_link "Upload / Import"
      #   find("#import-mentors").attach_file "Import Mentors", File.expand_path("./public/files/mentor_import.csv")
      #   click_button "Import Mentors"
      #   expect(page).to have_content("RESULTS:", "3 users created", "3 profiles created")
      # end
    end
  end
end
