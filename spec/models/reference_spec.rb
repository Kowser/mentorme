require 'spec_helper'

describe Reference do
  let(:mentor) { FactoryGirl.create(:mentor_full) }
  let(:reference) { FactoryGirl.create(:reference, mentor: mentor) }

  it 'should send an endorsement email with the correct URL & token' do
    reference
    ActionMailer::Base.deliveries.last.to.should eq [reference.email]
    ActionMailer::Base.deliveries.last.body.should match("#{reference.url_token}")
  end

  it 'should destroy the token associated with itself after being used' do
    reference.destroy_token
    reference.url_token.should eq nil
  end
end
