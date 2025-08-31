FactoryBot.define do
  factory :volunteer_shift do
    association :engagement_form
    organization_name { "MyString" }
    shift_date { Date.current - 1.week }
    hours { 9.99 }
  end
end
