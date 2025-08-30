require 'rails_helper'

RSpec.describe "Students", type: :request do
  let(:engagement_form) { EngagementForm.create!(user_name: "Test User", email: "test@example.com", organization: "Test Org") }

  describe "GET /new" do
    it "returns http success" do
      get "/engagement_forms/#{engagement_form.id}/students/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /create" do
    it "returns http success" do
      post "/engagement_forms/#{engagement_form.id}/students", params: { student_details: "Test student details" }
      expect(response).to have_http_status(:redirect)
    end
  end

end
