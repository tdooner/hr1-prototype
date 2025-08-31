module SessionHelper
  def set_engagement_form_session(engagement_form)
    # For RSpec request tests, we need to set the session before making the request
    # This is done by setting the session hash directly
    session[:engagement_form_id] = engagement_form.id
  end

  def clear_engagement_form_session
    session.delete(:engagement_form_id)
  end

  # Helper to create a basic engagement form session
  def create_engagement_form_session
    post "/engagement_forms", params: { 
      engagement_form: { 
        user_name: "John Doe", 
        email: "john@example.com", 
        application_date: Date.current 
      } 
    }
    follow_redirect!
  end

  # Helper to navigate to questions page with session
  def navigate_to_questions
    create_engagement_form_session
  end

  # Helper to navigate to jobs page with session
  def navigate_to_jobs
    create_engagement_form_session
    post "/questions", params: { has_job: "yes" }
    follow_redirect!
  end

  # Helper to navigate to students page with session
  def navigate_to_students
    create_engagement_form_session
    post "/questions", params: { is_student: "yes" }
    follow_redirect!
  end

  # Helper to navigate to work programs page with session
  def navigate_to_work_programs
    create_engagement_form_session
    post "/questions", params: { enrolled_work_program: "yes" }
    follow_redirect!
  end

  # Helper to navigate to volunteers page with session
  def navigate_to_volunteers
    create_engagement_form_session
    post "/questions", params: { volunteers_nonprofit: "yes" }
    follow_redirect!
  end

  # Helper to navigate to job paychecks page with session
  def navigate_to_job_paychecks
    navigate_to_jobs
    post "/jobs", params: {}
    follow_redirect!
  end

  # Helper to navigate to volunteer shifts page with session
  def navigate_to_volunteer_shifts
    navigate_to_volunteers
    post "/volunteers", params: { volunteer_details: "Test details" }
    follow_redirect!
  end

  # Helper to navigate to summary review page with session
  def navigate_to_summary_review
    navigate_to_jobs
    post "/jobs", params: {}
    follow_redirect!
  end

  # Helper to complete the entire form flow
  def complete_form_flow
    navigate_to_summary_review
    post "/summary/submit", params: {}
    follow_redirect!
  end
end

RSpec.configure do |config|
  config.include SessionHelper, type: :request
end
