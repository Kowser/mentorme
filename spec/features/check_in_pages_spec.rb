require 'spec_helper'

feature 'Check-In Pages' do
  let(:mentee) { FactoryGirl.create(:mentee_full) }
  let(:mentor) { FactoryGirl.create(:mentor_full) }

  context 'when mentor is logged in' do
    # it 'should allow a new check-in' do
    #   login(mentor.user)
    #   click_link "Check-In"
    #   select "In Person", from: "How did you meet"
    #   select 1, from: "How long did this meeting last? (# of hrs.)"
    #   select 3, from: "How happy were you with this meeting?"
    #   select 2014, from: "check_in_date_1i"
    #   select "April", from: "check_in_date_2i"
    #   select 28, from: "check_in_date_3i"
    #   click_link "Check-In"
    #   page.should have_content('Rating')
    # end

    it 'should show a history of check-ins' do
      FactoryGirl.create(:match, mentors: [mentor], mentees: [mentee])
      FactoryGirl.create_list(:check_in, 3, mentors: [mentor], mentees: [mentee])
      login(mentor.user)
      click_link "Check-In History"
      page.should have_content('Rating')
      page.should have_content('Total Check-Ins: 3')
    end
  end
end
