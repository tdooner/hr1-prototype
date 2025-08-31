require 'rails_helper'

RSpec.describe "Students", type: :request do
  describe "GET /new" do
    it "redirects to new form when no session exists" do
      get "/students/new"
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(new_engagement_form_path)
    end

    it "returns http success when session exists" do
      navigate_to_students
      get "/students/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /create" do
    before { navigate_to_students }

    it "handles half-time or more enrollment" do
      post "/students", params: { 
        school_name: "Test University", 
        enrollment_status: "half_time_or_more",
        school_hours: nil
      }
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(review_summary_path)
    end
    
    it "handles less than half-time enrollment with hours" do
      post "/students", params: { 
        school_name: "Test University", 
        enrollment_status: "less_than_half_time",
        school_hours: 10.5
      }
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(review_summary_path)
    end
  end
end
