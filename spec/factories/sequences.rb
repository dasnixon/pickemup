FactoryGirl.define do
  sequence(:email)   { |n| ('a'..'z').to_a.shuffle[0..15].join('') + '@email.com' }
  sequence(:guid)    { |n| "key_#{n}" }
  sequence(:integer) { |n| n }
  sequence(:name)    { |n| "Name #{n}" }
  sequence(:url)     { |n| "http://example.com/#{n}" }
end
