require 'rails_helper'

RSpec.describe "EngagementForms", type: :request do
  describe "GET /new" do
    it "returns http success" do
      get "/engagement_forms/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/engagement_forms/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/engagement_forms/show"
      expect(response).to have_http_status(:success)
    end
  end

end
