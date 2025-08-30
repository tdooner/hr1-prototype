require 'rails_helper'

RSpec.describe "JobPaychecks", type: :request do
  let(:engagement_form) { EngagementForm.create!(user_name: "Test User", email: "test@example.com", application_date: Date.current) }

  describe "GET /new" do
    it "returns http success" do
      get "/engagement_forms/#{engagement_form.id}/job_paychecks/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /create" do
    it "creates a new paycheck and redirects" do
      post "/engagement_forms/#{engagement_form.id}/job_paychecks", params: {
        job_paycheck: {
          pay_date: "2024-01-15",
          gross_pay_amount: "1500.00",
          hours_worked: "40.0"
        }
      }
      expect(response).to have_http_status(:redirect)
      expect(engagement_form.job_paychecks.count).to eq(1)
    end

    it "handles validation errors" do
      post "/engagement_forms/#{engagement_form.id}/job_paychecks", params: {
        job_paycheck: {
          pay_date: "",
          gross_pay_amount: "",
          hours_worked: ""
        }
      }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
