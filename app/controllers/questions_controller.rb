class QuestionsController < ApplicationController
  def new
    @engagement_form = EngagementForm.find(params[:engagement_form_id])
  end

  def create
    @engagement_form = EngagementForm.find(params[:engagement_form_id])
    
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
    
    # Determine the next step based on the answers
    next_step = determine_next_step(engagement_params)
    
    redirect_to next_step
  end
  
  private
  
  def determine_next_step(params)
    # Check each engagement type in order and route to the first one that's "yes"
    if params[:has_job] == "yes"
      new_engagement_form_job_path(@engagement_form)
    elsif params[:is_student] == "yes"
      new_engagement_form_student_path(@engagement_form)
    elsif params[:enrolled_work_program] == "yes"
      new_engagement_form_work_program_path(@engagement_form)
    elsif params[:volunteers_nonprofit] == "yes"
      new_engagement_form_volunteer_path(@engagement_form)
    else
      # If none are selected, go to review page
      review_summary_path(@engagement_form.id)
    end
  end
end
