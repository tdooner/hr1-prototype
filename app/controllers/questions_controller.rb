class QuestionsController < ApplicationController
  def new
    @engagement_form = current_engagement_form
  end

  def create
    @engagement_form = current_engagement_form

    # Handle both nested and direct parameters
    engagement_params = params[:engagement_form] || params

    # Update the engagement form with the checkbox answers
    # Checkboxes return "yes" when checked, nil when unchecked
    @engagement_form.update(
      has_job: engagement_params[:has_job] == "yes",
      is_student: engagement_params[:is_student] == "yes",
      enrolled_work_program: engagement_params[:enrolled_work_program] == "yes",
      volunteers_nonprofit: engagement_params[:volunteers_nonprofit] == "yes"
    )

    # Check if user came from review page
    if params[:from_review] == "true"
      redirect_to review_summary_path
    else
      # Use the new next_path method
      redirect_to next_path(@engagement_form)
    end
  end

  # Class method to determine if this controller should be skipped
  # Questions is always the first step, so it's never skipped
  def self.skip?(engagement_form)
    false
  end
end
