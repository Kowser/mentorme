require 'spec_helper'

describe Mentor do
  context 'when umbrella organization' do
    let(:mentor_partial) { FactoryGirl.create(:mentor) }

    it 'should send representative an email when a new mentor signs up' do
      partner = create_partner
      mentor_partial.user.roles_users.first.update(organization_id: partnerorganization.id)
      ActionMailer::Base.deliveries.first.to.should eq [partner.email]
    end

    it 'should validate at least one phone number is present' do
      mentor_partial.update(cell_phone: nil)
      mentor_partial.valid?.should be_false
    end

    it 'should return preferred phone number' do
      mentor_partial.cell_phone = "555-555-1234"
      mentor_partial.phone_preference = "Cell"
      mentor_partial.preferred_phone.should eq "555-555-1234"
    end
  end

  context 'when partner organization' do
    let(:mentor_full) { FactoryGirl.create(:mentor_full) }

    describe 'representative ' do
      let(:finish_application) {
        3.times do
          ref = FactoryGirl.build(:reference, mentor: mentor_full)
          mentor_full.update(references_attributes: { :id => ref.id, :name => ref.name, :email => ref.email, :phone => ref.phone, :relation => ref.relation })
        end
      }

      it 'is present, should get email' do
        partner = create_partner

        mentor_role = Role.where(name: "Mentor").first
        RolesUser.where(user_id: mentor_full.user.id, role_id: mentor_role.id).first.update(organization_id: partnerorganization.id)
        finish_application

        mail = ActionMailer::Base.deliveries
        mail[mail.length - 2].to.should eq [mentor_full.user.email]
        mail.last.to.should eq [partner.email]
      end

      it 'is absent, should email MentorMe admin' do
        finish_application

        mail = ActionMailer::Base.deliveries
        mail[mail.length - 2].to.should eq [mentor_full.user.email]
        mail.last.to.should eq ['admin@getmentorme.com']
      end
    end
  end
end
