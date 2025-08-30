require 'rails_helper'

RSpec.describe "EngagementForms", type: :request do
  describe "GET /new" do
    it "returns http success" do
      get "/engagement_forms/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /create" do
    it "returns http success" do
      post "/engagement_forms", params: { engagement_form: { user_name: "Test User", email: "test@example.com", organization: "Test Org" } }
      expect(response).to have_http_status(:redirect)
    end
  end

  describe "GET /show" do
    let(:engagement_form) { EngagementForm.create!(user_name: "Test User", email: "test@example.com", organization: "Test Org") }
    
    it "returns http success" do
      get "/engagement_forms/#{engagement_form.id}"
      expect(response).to have_http_status(:success)
    end
  end

end
