require 'rails_helper'

RSpec.describe "Summaries", type: :request do
  let(:engagement_form) { EngagementForm.create!(user_name: "Test User", email: "test@example.com", organization: "Test Org") }

  describe "GET /show" do
    it "returns http success" do
      get "/summary/#{engagement_form.id}"
      expect(response).to have_http_status(:success)
    end
  end

end
