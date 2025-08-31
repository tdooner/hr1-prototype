require 'rails_helper'

RSpec.describe "Summaries", type: :request do
  describe "GET /show" do
    it "redirects to new form when no session exists" do
      get "/summary"
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(new_engagement_form_path)
    end

    it "returns http success for completed form" do
      complete_form_flow
      get "/summary"
      expect(response).to have_http_status(:success)
    end

    it "redirects to review page for incomplete form" do
      navigate_to_summary_review
      get "/summary"
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(review_summary_path)
    end
  end

  describe "GET /review" do
    it "redirects to new form when no session exists" do
      get "/summary/review"
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(new_engagement_form_path)
    end

    it "returns http success when session exists" do
      navigate_to_summary_review
      get "/summary/review"
      expect(response).to have_http_status(:success)
    end

    it "displays the review form with edit links" do
      navigate_to_summary_review
      get "/summary/review"
      expect(response.body).to include("Review your information")
      expect(response.body).to include("Edit")
      expect(response.body).to include("Submit Form")
    end
  end

  describe "POST /submit" do
    it "redirects to new form when no session exists" do
      post "/summary/submit"
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(new_engagement_form_path)
    end

    it "marks form as completed and redirects to summary" do
      navigate_to_summary_review
      post "/summary/submit"
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(summary_path)
      
      # Verify the form was marked as completed
      engagement_form = EngagementForm.last
      expect(engagement_form.completed?).to be true
    end
  end
end
