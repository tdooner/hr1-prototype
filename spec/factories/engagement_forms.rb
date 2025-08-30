FactoryBot.define do
  factory :engagement_form do
    user_name { "MyString" }
    email { "MyString" }
    application_date { Date.current }
  end
end
