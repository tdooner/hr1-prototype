require 'rails_helper'

RSpec.describe "JobPaychecks", type: :request do
  describe "GET /new" do
    it "redirects to new form when no session exists" do
      get "/job_paychecks/new"
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(new_engagement_form_path)
    end

    it "returns http success when session exists" do
      navigate_to_job_paychecks
      get "/job_paychecks/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /create" do
    before { navigate_to_job_paychecks }

    it "creates a new paycheck and redirects" do
      post "/job_paychecks", params: {
        job_paycheck: {
          pay_date: "2024-01-15",
          gross_pay_amount: "1500.00",
          hours_worked: "40.0"
        }
      }
      expect(response).to have_http_status(:redirect)
      
      # Verify the paycheck was created
      engagement_form = EngagementForm.last
      expect(engagement_form.job_paychecks.count).to eq(1)
    end

    it "handles validation errors" do
      post "/job_paychecks", params: {
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
