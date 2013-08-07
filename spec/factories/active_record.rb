FactoryGirl.define do
  factory :user do
    github_uid    { generate(:guid) }
    linkedin_uid  { generate(:guid) }
    email         { generate(:email) }
    name          { generate(:name) }
    location      'San Francisco'
    main_provider 'github'
    profile_image 'http://www.dumpaday.com/wp-content/uploads/2011/04/Random-Funny-Photos-Part-132_14-2.jpg'
    description   'He is a developer'
  end

  factory :company do
    name          { generate(:name) }
    email         { generate(:email) }
    password      { generate(:guid) }
    description   'This is a company'
    website       'http://company.com'
    industry      'Sex'
    num_employees 10
  end

  factory :github_account do
    user
    nickname           { generate(:name) }
    hireable           true
    bio                'Balls hard on code all day playa'
    public_repos_count 10
    number_followers   10
    number_following   10
    number_gists       10
    blog               'http://blog.com'
    token              { generate(:guid) }
    github_account_key { generate(:guid) }
    uid                { generate(:guid) }
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

  factory :organization do
    github_account
    name               { generate(:name) }
    logo               'logo'
    url                { 'http://organization.com' }
    organization_key   { generate(:guid) }
    location           { generate(:name) }
    number_followers   10
    number_following   10
    blog               'http://blog.com'
    public_repos_count 10
    company_type       'Organization'
  end

  factory :position do
    profile
    industry     'Information Technology and Services'
    company_type 'Privately Held'
    name         { generate(:name) }
    size         '201-500 employees'
    company_key  { generate(:guid) }
    is_current   true
    title        'Software Engineer'
    summary      'Doing work son'
    start_year   '2012'
    start_month  '7'
  end

  factory :repo do
    github_account
    name           { generate(:name) }
    description    'This is a repository'
    url            'https://github.com'
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
    profile_url       'http://stackoverflow.com'
    repuation         100
    age               42
    badges            { { 'gold' => '0', 'bronze' => '0', 'silver' => '0' } }
    display_name      { generate(:name) }
    nickname          { generate(:name) }
    stackexchange_key { generate(:guid) }
  end
end
