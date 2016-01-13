require 'spec_helper'

describe User do
  let(:user) { FactoryGirl.create(:mentor_user) }

  it "should initialize with a role" do
    user.roles.empty?.should be_false
  end

  it "should retrieve its mentor organization" do
    user.organization.should be_true
  end

  it "should add and retrieve role regardless of case" do
    role = Role.find_by(name: "Admin")
    user.roles_users.create(:user_id => user.id, :organization_id => user.organization, :role_id => role.id)
    user.role?(:Admin).should be_true
    user.role?('Admin').should be_true
    user.role?('admin').should be_true
  end

end
