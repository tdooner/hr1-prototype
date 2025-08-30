require 'rails_helper'

RSpec.describe "EngagementForms", type: :request do
  let(:engagement_form) { EngagementForm.create!(user_name: "Test User", email: "test@example.com") }

  describe "GET /new" do
    it "returns http success" do
      get "/engagement_forms/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /create" do
    it "creates a new engagement form and redirects to questions" do
      post "/engagement_forms", params: { engagement_form: { user_name: "John Doe", email: "john@example.com" } }
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(new_engagement_form_question_path(EngagementForm.last))
    end
  end

  describe "GET /edit" do
    it "returns http success" do
      get "/engagement_forms/#{engagement_form.id}/edit"
      expect(response).to have_http_status(:success)
    end

    it "displays the form with existing data" do
      get "/engagement_forms/#{engagement_form.id}/edit"
      expect(response.body).to include("Edit Basic Information")
      expect(response.body).to include(engagement_form.user_name)
      expect(response.body).to include(engagement_form.email)

    end
  end

  describe "PATCH /update" do
    it "updates the engagement form and redirects to review" do
      patch "/engagement_forms/#{engagement_form.id}", params: { engagement_form: { user_name: "Updated Name", email: "updated@example.com" } }
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(review_summary_path(engagement_form))
      
      engagement_form.reload
      expect(engagement_form.user_name).to eq("Updated Name")
      expect(engagement_form.email).to eq("updated@example.com")
      
    end

    it "renders edit view with errors if validation fails" do
              patch "/engagement_forms/#{engagement_form.id}", params: { engagement_form: { user_name: "", email: "invalid-email" } }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("Edit Basic Information")
    end
  end
end
