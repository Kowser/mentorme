require 'spec_helper'

feature 'Match Pages' do
  let(:partner) { create_partner }
  let(:mentee) { FactoryGirl.create(:mentee_full) }
  let(:mentor) { FactoryGirl.create(:mentor_full) }
  let(:match) { FactoryGirl.create(:match, mentors: [mentor], mentees: [mentee], organization: partnerorganization) }
  let(:matches) { FactoryGirl.create_list(:match, 3,  mentors: [mentor], mentees: [mentee], organization: partnerorganization) }

  context 'when partner user' do

    it 'should show Create Matches panel' do
      login(partner)
      click_link "Matches"
      page.should have_content('Create Matches')
    end

    it 'should show an index of matches' do
      matches # activates respective FactoryGirl
      login(partner)
      click_link "Matches"
      page.should have_content('Create Matches')
      page.should have_content(mentor.user.name)
      page.should have_content(mentor.user.name)
      page.should have_content("Total: #{Match.count}")
    end

    it 'should display an individual matches information' do
      match.update(staff_notes: '123 ABC Notes')
      login(partner)
      click_link "Matches"
      click_link "View / Edit"
      page.should have_content('123 ABC Notes')
    end

    it 'should show Create Matches panel' do
      match
      login(partner)
      click_link "Matches"
      page.should have_content('Create Matches')
    end

    it 'should show Add Goals panel' do
      match
      login(partner)
      click_link "Matches"
      click_link "View / Edit"
      page.should have_content('Add Goal')
    end

    describe 'Goals' do
      it 'should create a new goal' do
        create_goal
        expect(page).to have_content "Volunteer locally"
      end

      it 'should delete a new goal' do
        match
        login(partner)
        click_link "Matches"
        click_link "View / Edit"
        click_link "Add Goal"
        fill_in('Title', with: "Volunteer locally")
        click_button "Add"
        click_link "Delete"
        expect(page).not_to have_content "Volunteer locally"
      end

      describe 'When Goal is not complete' do
        it 'should have content Incomplete' do
          create_goal
          expect(page).to have_content "Incomplete"
        end
        it 'should not have content Unverified' do
          create_goal
          expect(page).not_to have_content "Unverified"
        end
      end
    end
  end

  context 'when mentor user' do
    it 'should show an index of matches' do
      match
      login(mentor.user)
      click_link "Matches"
      page.should have_content(mentee.user.name)
      page.should have_content(mentor.user.name)
      page.should_not have_content('Create Matches')
    end
  end

  context 'when mentee user' do
    it 'should show and index of matches' do
      match
      login(mentee.user)
      click_link "Matches"
      page.should have_content(mentee.user.name)
      page.should have_content(mentor.user.name)
      page.should_not have_content('Create Matches')
    end
  end
end
