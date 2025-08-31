require 'rails_helper'

RSpec.describe "Volunteers", type: :request do
  describe "GET /new" do
    it "redirects to new form when no session exists" do
      get "/volunteers/new"
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(new_engagement_form_path)
    end

    it "returns http success when session exists" do
      navigate_to_volunteers
      get "/volunteers/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /create" do
    before { navigate_to_volunteers }

    it "handles volunteer creation" do
      post "/volunteers", params: { volunteer_details: "Test volunteer details" }
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(review_summary_path)
    end
  end
end
