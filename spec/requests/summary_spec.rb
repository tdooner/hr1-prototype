require 'rails_helper'

RSpec.describe "Summaries", type: :request do
  let(:engagement_form) { EngagementForm.create!(user_name: "Test User", email: "test@example.com", organization: "Test Org") }

  describe "GET /show" do
    it "returns http success for completed form" do
      engagement_form.update(completed: true)
      get "/summary/#{engagement_form.id}"
      expect(response).to have_http_status(:success)
    end

    it "redirects to review page for incomplete form" do
      get "/summary/#{engagement_form.id}"
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(review_summary_path(engagement_form))
    end
  end

  describe "GET /review" do
    it "returns http success" do
      get "/summary/#{engagement_form.id}/review"
      expect(response).to have_http_status(:success)
    end

    it "displays the review form with edit links" do
      get "/summary/#{engagement_form.id}/review"
      expect(response.body).to include("Review Your Community Engagement Form")
      expect(response.body).to include("Edit")
      expect(response.body).to include("Submit Form")
    end
  end

  describe "POST /submit" do
    it "marks form as completed and redirects to summary" do
      post "/summary/#{engagement_form.id}/submit"
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(summary_path(engagement_form))
      
      engagement_form.reload
      expect(engagement_form.completed?).to be true
    end
  end
end
