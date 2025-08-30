require 'rails_helper'

RSpec.describe "Volunteers", type: :request do
  let(:engagement_form) { EngagementForm.create!(user_name: "Test User", email: "test@example.com") }

  describe "GET /new" do
    it "returns http success" do
      get "/engagement_forms/#{engagement_form.id}/volunteers/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /create" do
    it "returns http success" do
      post "/engagement_forms/#{engagement_form.id}/volunteers", params: { volunteer_details: "Test volunteer details" }
      expect(response).to have_http_status(:redirect)
    end
  end

end
