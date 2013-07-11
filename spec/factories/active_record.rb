FactoryGirl.define do
  factory :user do
    email    { generate(:email) }
    name     { generate(:name) }
    location 'San Francisco'
    blog     'http://blog.com'
    uid      { generate(:guid) }
  end
end
