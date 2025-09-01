require 'rails_helper'

RSpec.describe "Questions", type: :request do
  let(:engagement_form) { EngagementForm.create!(user_name: "Test User", email: "test@example.com", application_date: Date.current) }

  describe "GET /new" do
    it "redirects to new form when no session exists" do
      get "/questions/new"
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(new_engagement_form_path)
    end

    it "returns http success when session exists" do
      navigate_to_questions
      get "/questions/new"
      expect(response).to have_http_status(:success)
    end

    it "displays the questions form with checkboxes" do
      navigate_to_questions
      get "/questions/new"
      expect(response.body).to include("Check any of these that apply:")
      expect(response.body).to include("I have a job")
      expect(response.body).to include("I am a student")
      expect(response.body).to include("I am enrolled in a work program")
      expect(response.body).to include("I volunteer with a nonprofit organization")
    end

    it "displays informational text outside of alert component" do
      navigate_to_questions
      get "/questions/new"
      expect(response.body).to include("To meet the Medicaid Community Engagement Requirements")
      expect(response.body).not_to include("usa-alert")
    end
  end

  describe "POST /create" do
    before { navigate_to_questions }

    it "handles no selections and redirects to review page" do
      post "/questions", params: {}
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(review_summary_path)
    end

    it "handles job selection and redirects to job form" do
      post "/questions", params: { has_job: "yes" }
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(new_job_path)
    end

    it "handles student selection and redirects to student form" do
      post "/questions", params: { is_student: "yes" }
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(new_student_path)
    end

    it "handles work program selection and redirects to work program form" do
      post "/questions", params: { enrolled_work_program: "yes" }
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(new_work_program_path)
    end

    it "handles volunteer selection and redirects to volunteer form" do
      post "/questions", params: { volunteers_nonprofit: "yes" }
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(new_volunteer_path)
    end

    it "prioritizes job over other selections" do
      post "/questions", params: {
        has_job: "yes",
        is_student: "yes",
        enrolled_work_program: "yes",
        volunteers_nonprofit: "yes"
      }
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(new_job_path)
    end

    it "updates engagement form with correct boolean values" do
      post "/questions", params: {
        has_job: "yes",
        is_student: "yes",
        enrolled_work_program: "no",
        volunteers_nonprofit: "no"
      }

      # Get the engagement form from the session
      engagement_form = EngagementForm.last
      expect(engagement_form.has_job?).to be true
      expect(engagement_form.is_student?).to be true
      expect(engagement_form.enrolled_work_program?).to be false
      expect(engagement_form.volunteers_nonprofit?).to be false
    end
  end
end
