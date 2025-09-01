require 'rails_helper'

RSpec.describe "VolunteerShifts", type: :request do
  describe "GET /new" do
    it "redirects to new form when no session exists" do
      get "/volunteer_shifts/new"
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(new_engagement_form_path)
    end

    it "returns http success when session exists" do
      navigate_to_volunteer_shifts
      get "/volunteer_shifts/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /create" do
    before { navigate_to_volunteer_shifts }

    it "creates a new volunteer shift and redirects" do
      post "/volunteer_shifts", params: {
        volunteer_shift: {
          organization_name: "Test Organization",
          shift_date: "2024-01-15",
          hours: "4.5"
        }
      }
      expect(response).to have_http_status(:redirect)

      # Verify the volunteer shift was created
      engagement_form = EngagementForm.last
      expect(engagement_form.volunteer_shifts.count).to eq(1)
    end

    it "handles validation errors" do
      post "/volunteer_shifts", params: {
        volunteer_shift: {
          organization_name: "",
          shift_date: "",
          hours: ""
        }
      }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
