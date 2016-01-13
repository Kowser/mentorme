FactoryGirl.define do
  factory :organization do
    factory :mentorme_organization do
      name 'MentorMe, Inc.'
      email 'someone@getmentorme.kom'
      subdomain 'www'
      phone_number '901-555-5555'
      address1 '123 Main St'
      address2 ''
      city 'Memphis'
      state 'TN'
      zip_code '38111'
      about_us "MentorMe is a unique, cloud-based platform built for mentoring programs by people who mentor"
      url 'http://www.getmentorme.com'
      type 'Umbrella'
    end

    factory :umbrella_organization do
      name 'Grizzlies Charitable Foundation'
      email 'someone@grizzliescf.kom'
      subdomain 'grizzlies'
      phone_number '901-555-3333'
      address1 '225 Main St'
      address2 ''
      city 'Memphis'
      state 'TN'
      zip_code '38104'
      about_us "Grizzlies Foundation is awesome"
      url 'http://www.grizzliescf.org'
      type 'Umbrella'
    end

    factory :partner_organization do
      name 'Hogwarts School of Witchcraft'
      email 'information@organization.com'
      subdomain 'hogwarts'
      phone_number '503-555-1111'
      address1 '4 Privet Drive'
      address2 'Cupboard under the stairs'
      city 'Little Whinging'
      state 'AK'
      zip_code '98765'
      about_us 'Where the best witches and wizards learn their craft'
      url 'http://www.hogwarts.com'
      type 'Partner'
    end
  end

  factory :user do
    password 'password'
    password_confirmation 'password'
    confirmed_at Time.now
    org_id { create(:umbrella_organization).id }

    factory :mentor_user do
      name 'Harry Mentor'
      as_a 'Mentor'
      sequence(:email) {|n| "mentor#{n}@example.com" }
    end

    factory :mentee_user do
      name 'Mentee Kiddo'
      as_a 'Mentee'
      sequence(:email) {|n| "mentee#{n}@example.com" }
    end

    factory :partner_user do
      name 'Partner Pizzano'
      sequence(:email) {|n| "partner#{n}@example.com" }
      as_a 'Mentor'
    end

    factory :admin_user do
      name 'Admin Annie'
      as_a 'Mentor'
      sequence(:email) {|n| "admin#{n}@example.com" }
      org_id { create(:mentorme_organization).id }
    end
  end

  factory :mentor do
    user factory: :mentor_user
    gender 'Male'
    birth_date '06/01/1970'
    address1 '123 Main St.'
    city 'San Francisco'
    state 'CA'
    zip '12345'
    cell_phone '212-321-9875'
    phone_preference 'Cell'
    referred_by 'Referral - friend'
    mentee_age_preference '5-11'
    mentoring_type 'Sports team (coaching)'
    format_preference 'Community-based (doing activities with my mentee out in the community'
    availability 'Weekdays after school hours (3 p.m. - 5 p.m.)'
    distance '10 miles or less'
    will_commit_minimum 'Yes'
    will_commit_weekly 'Yes'
    will_interview_orientate 'Yes'
    employer_name 'Employer Information'
    employer_job_title 'Employer Information'
    employer_length 'Employer Information'
    employer_address1 'Employer Information'
    employer_address2 'Employer Information'
    employer_city 'Employer Information'
    employer_state 'Employer Information'
    employer_zip 'Employer Information'
    ethnicity 'Hispanic/Latino'
    english_first_language 'No'
    education 'High School Diploma or GED'

    factory :mentor_full do
      support_goal 'Cultural enrichment'
      prior_experience 'Other'
      backgrounds 'I had an absent parent'
      will_allow_background_check 'AGREE'
    end
  end

  factory :mentee do
    user factory: :mentee_user
    guardian_name 'Frank Father'
    relation 'Father'
    gender 'Male'
    birth_date '02/25/2004'
    address1 '123 ABC Street'
    address2 'Apt 120C'
    city 'Gnome'
    state 'AK'
    zip '90001'
    school 'Gnomenclature'
    grade '4'
    guardian_cell_phone '987-654-3210'
    guardian_phone_preference 'Cell'
    referred_by 'Referral - friend'
    mentoring_type 'Sports team (coaching)'
    format_preference 'Community-based (doing activities with my mentee out in the community'
    availability 'Weekdays after school hours (3 p.m. - 5 p.m.)'
    distance '10 miles or less'
    will_commit_minimum 'Yes'
    will_commit_weekly 'Yes'
    will_interview_orientate 'Yes'
    ethnicity "Native Hawaiian or Other Pacific Islander"
    english_first_language "Yes"

    factory :mentee_full do
      multilingual "Yes"
      support_goal "Cultural enrichment"
      backgrounds "I have experienced the death of a parent"
    end
  end

  factory :reference do
    mentor factory: :mentor_full
    name 'George'
    sequence(:email) {|n| "reference#{n}@example.com" }
    phone '123456789'
    relation 'Manager'
  end

  factory :match do
    organization factory: :partner_organization
  end

  factory :check_in do
    length 5
    location 'School'
    date Time.now - 1.day
    ratings [Rating.new(rating: 4, notes: 'blah da bla dy blah')]
    goals 'Goals, this is about results!'
    next_date Time.now + 6.days
  end

  factory :goal do
    title "This is a new goal!"
    # match factory: :match
  end
end
