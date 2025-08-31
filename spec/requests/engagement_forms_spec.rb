require 'rails_helper'

RSpec.describe "EngagementForms", type: :request do
  let(:engagement_form) { EngagementForm.create!(user_name: "Test User", email: "test@example.com", application_date: Date.current) }

  describe "GET /new" do
    it "returns http success" do
      get "/engagement_forms/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /create" do
    it "creates a new engagement form and redirects to questions" do
      post "/engagement_forms", params: { engagement_form: { user_name: "John Doe", email: "john@example.com", application_date: Date.current } }
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(new_question_path)
    end
  end

  describe "session management" do
    it "sets session when creating new form" do
      post "/engagement_forms", params: { engagement_form: { user_name: "John Doe", email: "john@example.com", application_date: Date.current } }
      
      # Check that the session was set by following the redirect
      follow_redirect!
      expect(response).to have_http_status(:success)
    end

    it "redirects to new form when no session exists" do
      get "/questions/new"
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(new_engagement_form_path)
    end
  end
end
