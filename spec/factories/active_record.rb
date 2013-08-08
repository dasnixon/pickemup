FactoryGirl.define do
  factory :user do
    github_uid    { generate(:guid) }
    linkedin_uid  { generate(:guid) }
    email         { Faker::Internet.email }
    name          { Faker::Name.name }
    location      { "#{Faker::Address.city}, #{Faker::AddressUS.state}" }
    main_provider 'github'
    profile_image { Faker::Internet.http_url }
    description   { Faker::Lorem.sentences.join(' ') }
  end

  factory :company do
    name          { Faker::Company.name }
    email         { Faker::Internet.email }
    password      { generate(:guid) }
    description   { Faker::Lorem.sentences.join(' ') }
    website       { Faker::Internet.http_url }
    industry      { Faker::Lorem.word }
    num_employees 10
  end

  factory :github_account do
    user
    nickname           { Faker::Name.name }
    hireable           true
    bio                { Faker::Lorem.sentences.join(' ') }
    public_repos_count 10
    number_followers   10
    number_following   10
    number_gists       10
    blog               { Faker::Internet.http_url }
    token              { generate(:guid) }
    github_account_key { generate(:guid) }
    uid                { generate(:guid) }
  end

  factory :education do
    profile
    activities     { Faker::Lorem.sentences.join(' ') }
    degree         { Faker::Education.degree }
    field_of_study { Faker::Education.major }
    notes          { Faker::Lorem.sentences.join(' ') }
    school_name    { Faker::Education.school_name }
    start_year     { '2013' }
    end_year       { '2018' }
    education_key  { generate(:guid) }
  end

  factory :profile do
    linkedin
    number_connections  10
    number_recommenders 10
    summary             { Faker::Lorem.sentences.join(' ') }
    skills              ['Ruby', 'Ruby on Rails']
  end

  factory :linkedin do
    user
    token       { generate(:guid) }
    headline    { Faker::Lorem.sentence }
    industry    { Faker::Lorem.word }
    uid         { generate(:guid) }
    profile_url { Faker::Internet.http_url }
  end

  factory :organization do
    github_account
    name               { Faker::Name.name }
    logo               { Faker::Lorem.word }
    url                { Faker::Internet.http_url }
    organization_key   { generate(:guid) }
    location           { "#{Faker::Address.city}, #{Faker::AddressUS.state}" }
    number_followers   10
    number_following   10
    blog               { Faker::Internet.http_url }
    public_repos_count 10
    company_type       { Faker::Lorem.word }
  end

  factory :position do
    profile
    industry     { Faker::Lorem.words }
    company_type { Faker::Lorem.words }
    name         { Faker::Company.name }
    size         '201-500 employees'
    company_key  { generate(:guid) }
    is_current   true
    title        { Faker::Company.position }
    summary      { Faker::Lorem.sentences.join(' ') }
    start_year   '2012'
    start_month  '7'
  end

  factory :repo do
    github_account
    name           { Faker::Name.name }
    description    { Faker::Lorem.sentences.join(' ') }
    url            { Faker::Internet.http_url }
    language       'Ruby'
    number_forks    5
    number_watchers 5
    size            50
    open_issues     4
    started         Date.yesterday
    last_updated    Date.today
    repo_key        { generate(:guid) }
  end

  factory :stackexchange do
    user
    token             { generate(:guid) }
    uid               { generate(:guid) }
    profile_url       { Faker::Internet.http_url }
    repuation         100
    age               42
    badges            { { 'gold' => '0', 'bronze' => '0', 'silver' => '0' } }
    display_name      { Faker::Name.name }
    nickname          { Faker::Name.name }
    stackexchange_key { generate(:guid) }
  end
end
