FactoryBot.define do
  factory :job_paycheck do
    association :engagement_form
    pay_date { Date.current - 1.week }
    gross_pay_amount { 1500.00 }
    hours_worked { 40.0 }
  end
end
