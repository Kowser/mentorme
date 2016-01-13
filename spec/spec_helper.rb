# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'factory_girl'
require 'capybara/rails'
require 'capybara/rspec'
require 'capybara/poltergeist'


def switch_to_subdomain(subdomain)
  # lvh.me always resolves to 127.0.0.1
  hostname = subdomain ? "#{subdomain}.lvh.me" : "lvh.me"
  Capybara.app_host = "http://#{hostname}"
end

def switch_to_main_domain
  switch_to_subdomain nil
end

def login(user)
  visit 'http://lvh.me:3000/sign_in'
  fill_in 'user_email', with: user.email
  fill_in 'Password', with: 'password'
  click_button('Login')
end

def logout
  click_link "Sign Out"
end

def create_partner
  partner = FactoryGirl.create(:partner_user, org_id: FactoryGirl.create(:partner_organization).id)
  partner_role = Role.find_by(name: "Partner")
  partner.roles_users.create(role_id: partner_role.id, organization_id: partner.organization.id)
  partner.roles_users.find_by(role: Role.find_by(name: "Mentor")).delete # DELETE THE PARTNER'S MENTOR ROLE
  partner
end

def create_admin
  admin = FactoryGirl.create(:admin_user)
  admin_role = Role.find_by(name: "Admin")
  admin.roles_users.first.delete # DELETE THE ADMIN'S MENTOR ROLE
  admin.roles_users.create(role_id: admin_role.id)
  admin
end

def create_goal
  match
  login(partner)
  click_link "Matches"
  click_link "View / Edit"
  click_link "Add Goal"
  fill_in('Title', with: "Volunteer locally")
  click_button "Add"
end

def wait_for_ajax
  counter = 0
  while page.execute_script("return $.active").to_i > 0
    counter += 1
    sleep(0.1)
    raise "AJAX request took longer than 5 seconds." if counter >= 50
  end
end

def seed_database
  unless Organization.find_by(subdomain: 'www')
    Organization.delete_all
    FactoryGirl.create(:mentorme_organization)
  end

  unless Role.count == 4
    Role.delete_all
    FactoryGirl.create(:mentor_role)
    FactoryGirl.create(:mentee_role)
    FactoryGirl.create(:partner_role)
    FactoryGirl.create(:admin_role)
  end
end

RSpec.configure do |config|
  switch_to_main_domain
  seed_database
end

Capybara.configure do |config|
  config.always_include_port = true
end

Capybara.javascript_driver = :poltergeist

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)

RSpec.configure do |config|
  config.before(:each) do
    ActionMailer::Base.deliveries.clear
  end

  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"
end
