require 'rails_helper'

RSpec.describe "WorkPrograms", type: :request do
  describe "GET /new" do
    it "redirects to new form when no session exists" do
      get "/work_programs/new"
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(new_engagement_form_path)
    end

    it "returns http success when session exists" do
      navigate_to_work_programs
      get "/work_programs/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /create" do
    before { navigate_to_work_programs }

    it "handles work program creation" do
      post "/work_programs", params: {
        work_program_name: "Test Work Program",
        hours_attended: 40.5
      }
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(review_summary_path)
    end
  end
end
