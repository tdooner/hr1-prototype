require 'rails_helper'

RSpec.describe "Jobs", type: :request do
  describe "GET /new" do
    it "redirects to new form when no session exists" do
      get "/jobs/new"
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(new_engagement_form_path)
    end

    it "returns http success when session exists" do
      navigate_to_jobs
      get "/jobs/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /create" do
    before { navigate_to_jobs }

    it "redirects to next step after successful creation" do
      post "/jobs", params: {}
      expect(response).to have_http_status(:redirect)
      # Should redirect to the next step in the flow
      expect(response).to redirect_to(review_summary_path)
    end
  end
end
