require 'rails_helper'

RSpec.describe "Questions", type: :request do
  let(:engagement_form) { EngagementForm.create!(user_name: "Test User", email: "test@example.com", organization: "Test Org") }

  describe "GET /new" do
    it "returns http success" do
      get "/engagement_forms/#{engagement_form.id}/questions/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /create" do
    it "returns http success" do
      post "/engagement_forms/#{engagement_form.id}/questions", params: { has_job: "no", is_student: "no", enrolled_work_program: "no", volunteers_nonprofit: "no" }
      expect(response).to have_http_status(:redirect)
    end
  end

end
