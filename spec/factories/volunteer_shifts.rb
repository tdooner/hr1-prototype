FactoryBot.define do
  factory :volunteer_shift do
    engagement_form { nil }
    organization_name { "MyString" }
    shift_date { "2025-08-30" }
    hours { "9.99" }
  end
end
