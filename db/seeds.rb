Role.where(name: 'Mentor').first_or_create!
Role.where(name: 'Mentee').first_or_create!
Role.where(name: 'Partner').first_or_create!
Role.where(name: 'Admin').first_or_create!

Organization.new(
  name: 'MentorMe, Inc.',
  contact_email: 'brit@getmentorme.com',
  notification_email: 'brit@getmentorme.com',
  subdomain: 'www',
  about_us: 'MentorMe Umbrella Org',
  phone_number: '901-111-1111',
  address1: '88 Main St.',
  address2: '',
  city: 'Memphis',
  state: 'TN',
  zip_code: '38104',
  url: 'http://www.getmentorme.com',
  role: 'Umbrella'
).save( validate: false)

if Rails.env == "development"
  Organization.new(
    name: 'Hogwarts School of Witchcraft',
    contact_email: 'information@organization.com',
    notification_email: 'information@organization.com',
    subdomain: 'hogwarts',
    phone_number: '503-555-55555',
    address1: '4 Privet Drive',
    address2: 'Cupboard under the stairs',
    city: 'Little Whinging',
    state: 'AK',
    zip_code: '98765',
    about_us: 'Where the best witches and wizards learn their craft',
    url: 'http://www.hogwarts.com',
    role: 'Partner',
    umbrella: Organization.first
  ).save(validate: false)

  Mentor.delete_all
  Mentee.delete_all
  User.delete_all
  Match.delete_all

  3.times do |n|
    mentor_user = User.create!(
      name: Faker::Name.name,
      role: 'Mentor',
      email: "mentor-#{n+1}@example.com",
      phone: "",
      login: "mentor-#{n+1}@example.com",
      password: 'password',
      password_confirmation: 'password',
      confirmed_at: Time.now,
      role: 'Mentor',
      organization_id: Organization.last.id
    )

    Mentor.create!(
      user: mentor_user,
      gender: (Random.rand(2) % 2 == 0) ? 'Female' : 'Male',
      birth_date: '06/01/1970',
      address1: '123 Main St.',
      city: 'Memphis',
      state: 'TN',
      zip: '38028',
      cell_phone: '212-321-9875',
      employer_name: 'MentorMe Inc.',
      employer_job_title: 'Some Title',
      employer_length: '5 years',
      employer_address1: '123 Employer Ave',
      employer_city: 'Memphis',
      employer_state: 'TN',
      employer_zip: '38028',
      phone_preference: 'Cell',
      referred_by: 'Referral - friend',
      ethnicity: 'Eskimo',
      mentee_age_preference: ['Primary school (ages 8-10)'],
      mentoring_type: ['Sports team (coaching)'],
      format_preference: ['School-based (meeting my mentee at his or her school)'],
      availability: ['Evenings (after 5 p.m.)'],
      distance: '< 5 miles',
      will_commit_minimum: 'Yes',
      will_commit_weekly: 'Yes',
      will_interview_orientate: 'Yes'
    )

    mentee_user = User.create(
      name: Faker::Name.name,
      email: "mentee-#{n+1}@example.com",
      phone: '',
      login: "mentee-#{n+1}@example.com",
      password: 'password',
      password_confirmation: 'password',
      confirmed_at: Time.now,
      role: 'Mentee',
      organization_id: Organization.last.id
    )

    Mentee.create!(
      user: mentee_user,
      gender: (Random.rand(2) % 2 == 0) ? 'Female' : 'Male',
      birth_date: '02/25/2004',
      address1: '123 ABC Street',
      address2: 'Apt 120C',
      city: 'Gnome',
      state: 'AK',
      zip: '90001',
      school: 'Gnomenclature',
      ethnicity: 'Eskimo',
      grade: '4',
      guardian_name: 'Mommy Parent',
      relation: 'Mother',
      guardian_cell_phone: '987-654-3210',
      guardian_phone_preference: 'Cell',
      referred_by: 'Referral - friend',
      mentoring_type: ['Sports team (coaching)'],
      format_preference: ['School-based (meeting my mentee at his or her school)'],
      availability: ['Evenings (after 5 p.m.)'],
      distance: '5-10 miles',
      will_commit_minimum: 'Yes',
      will_commit_weekly: 'Yes',
      will_interview_orientate: 'Yes'
    )
  end

  User.create!(
    name: 'Umbrella Umma',
    email: 'umbrella@example.com',
    phone: '',
    login: 'umbrella@example.com',
    password: 'password',
    password_confirmation: 'password',
    confirmed_at: Time.now,
    admin_created: true,
    organization: Organization.first,
    role: 'Partner'
  )

  User.create!(
    name: 'Partner Pizzano',
    email: 'partner@example.com',
    phone: '',
    login: 'partner@example.com',
    password: 'password',
    password_confirmation: 'password',
    confirmed_at: Time.now,
    admin_created: true,  
    organization: Organization.last,
    role: 'Partner'
  )

  User.create!(
    name: 'Admin Annie',
    email: 'admin@example.com',
    phone: '',
    login: 'admin@example.com',
    password: 'password',
    password_confirmation: 'password',
    confirmed_at: Time.now,
    admin_created: true,
    organization: Organization.first,
    role: 'Admin'
  )
end
