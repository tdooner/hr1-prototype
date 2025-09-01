FactoryBot.define do
  factory :engagement_form do
    user_name { "John Doe" }
    email { "john.doe@example.com" }
    application_date { Date.current }

    trait :without_application_date do
      application_date { nil }
    end
  end
end
