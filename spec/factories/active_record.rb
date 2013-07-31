FactoryGirl.define do
  factory :user do
    email    { generate(:email) }
    name     { generate(:name) }
    location 'San Francisco'
    blog     'http://blog.com'
    uid      { generate(:guid) }
  end

  factory :education do
    profile
    activities     'Chess club fa sho'
    degree         'Computer Engineering'
    field_of_study 'Engineering'
    notes          'Some notes'
    school_name    { generate(:name) }
    start_year     { '2013' }
    end_year       { '2018' }
    education_key  { generate(:guid) }
  end

  factory :profile do
    linkedin
    number_connections  10
    number_recommenders 10
    summary             'My profile is cool'
    skills              ['Ruby', 'Ruby on Rails']
  end

  factory :linkedin do
    user
    token       { generate(:guid) }
    headline    'Baller Developer'
    industry    'Computer Software'
    uid         { generate(:guid) }
    profile_url 'https://linkedin.com'
  end
end
