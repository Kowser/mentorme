require 'spec_helper'

describe Organization do
  let(:partner_org) { FactoryGirl.create(:partner_organization) }
  let(:umbrella_org) { FactoryGirl.create(:umbrella_organization) }
  let(:mentee) { FactoryGirl.create(:mentee_full) }
  let(:mentor) { FactoryGirl.create(:mentor_full) }

  it 'as umbrella should be valid' do
    umbrella_org.valid?.should be_true
  end

  it 'as partner should be valid' do
    partner_org.valid?.should be_true
  end

  it 'should return a list of users who are mentors' do
    FactoryGirl.create_list(:mentor_user, 5, org_id: umbrella_org.id)
    FactoryGirl.create(:mentee_user, org_id: umbrella_org.id)
    umbrella_org.users(:mentor).count.should eq 5
  end

  it 'should return a list of users who are mentees' do
    FactoryGirl.create_list(:mentee_user, 5, org_id: partner_org.id)
    FactoryGirl.create(:mentor_user, org_id: partner_org.id)
    partner_org.users(:mentee).count.should eq 5
  end

  it 'should return a list of partner users' do
    partner = create_partner
    FactoryGirl.create(:mentor_user, org_id: partnerorganization.id)
    FactoryGirl.create(:mentee_user, org_id: partnerorganization.id)
    partnerorganization.staff.count.should eq 1
  end

  it "returns its representative, if available" do
    partner_user = create_partner
    partner_userorganization.staff.should eq [partner_user]
  end

  describe '#import_users' do
    it 'should create 2 users and 2 mentor profiles' do
      import_type = 'Mentor'
      file = File.new(Rails.root + 'public/files/mentor_import.csv')
      partner_org.import_users(file, import_type)
      partner_org.mentors.count.should eq 2
    end

    it 'should create 2 users and 2 mentee profiles' do
      import_type = 'Mentee'
      file = File.new(Rails.root + 'public/files/mentee_import.csv')
      partner_org.import_users(file, import_type)
      partner_org.mentees.count.should eq 2
    end
  end

  describe '#import_matches' do
    it 'should create matches based on valid email addresses' do
      partner_org.import_users(File.new(Rails.root + 'public/files/mentor_import.csv'), 'Mentor')
      partner_org.import_users(File.new(Rails.root + 'public/files/mentee_import.csv'), 'Mentee')
      file = File.new(Rails.root + 'public/files/matches_import.csv')
      partner_org.import_matches(file)
      partner_org.matches.count.should eq 3
    end
  end

  # This method will be changing so should currently fail
  describe '#checkins_since' do
    it 'should count check ins of an organizations mentors since a given date' do
      match = FactoryGirl.create(:match, mentors: [mentor], mentees: [mentee], organization: partner_org)
      check_in = FactoryGirl.create(:check_in, match_id: match.id, mentors: [mentor], mentees: [mentee])
      match.organization.checkins_since('week').should eq 1
    end
  end
end
