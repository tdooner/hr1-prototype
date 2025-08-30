class QuestionsController < ApplicationController
  def new
    @engagement_form = EngagementForm.find(params[:engagement_form_id])
  end

  def create
    @engagement_form = EngagementForm.find(params[:engagement_form_id])
    
    # Update the engagement form with the yes/no answers
    @engagement_form.update(
      has_job: params[:has_job] == "yes",
      is_student: params[:is_student] == "yes",
      enrolled_work_program: params[:enrolled_work_program] == "yes",
      volunteers_nonprofit: params[:volunteers_nonprofit] == "yes"
    )
    
    # Determine the next step based on the answers
    next_step = determine_next_step(params)
    
    redirect_to next_step
  end
  
  private
  
  def determine_next_step(params)
    # Check each engagement type in order and route to the first one that's "yes"
    if params[:has_job] == "yes"
      new_job_path(engagement_form_id: @engagement_form.id)
    elsif params[:is_student] == "yes"
      new_student_path(engagement_form_id: @engagement_form.id)
    elsif params[:enrolled_work_program] == "yes"
      new_work_program_path(engagement_form_id: @engagement_form.id)
    elsif params[:volunteers_nonprofit] == "yes"
      new_volunteer_path(engagement_form_id: @engagement_form.id)
    else
      # If none are selected, go to summary
      summary_path(@engagement_form.id)
    end
  end
end
