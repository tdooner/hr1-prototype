require 'rails_helper'

RSpec.describe "Students", type: :request do
  let(:engagement_form) { EngagementForm.create!(user_name: "Test User", email: "test@example.com") }

  describe "GET /new" do
    it "returns http success" do
      get "/engagement_forms/#{engagement_form.id}/students/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /create" do
    it "returns http success" do
      post "/engagement_forms/#{engagement_form.id}/students", params: { 
        school_name: "Test University", 
        enrollment_status: "half_time_or_more",
        school_hours: nil
      }
      expect(response).to have_http_status(:redirect)
    end
    
    it "handles less than half-time enrollment with hours" do
      post "/engagement_forms/#{engagement_form.id}/students", params: { 
        school_name: "Test University", 
        enrollment_status: "less_than_half_time",
        school_hours: 10.5
      }
      expect(response).to have_http_status(:redirect)
    end
  end

end
