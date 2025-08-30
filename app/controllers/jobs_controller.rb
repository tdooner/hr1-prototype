class JobsController < ApplicationController
  def new
    @engagement_form = EngagementForm.find(params[:engagement_form_id])
  end

  def create
    @engagement_form = EngagementForm.find(params[:engagement_form_id])
    
    @engagement_form.update(job_details: params[:job_details])
    
    # Determine next step based on remaining engagement types
    next_step = determine_next_step
    
    redirect_to next_step
  end
  
  private
  
  def determine_next_step
    if @engagement_form.is_student?
      new_student_path(engagement_form_id: @engagement_form.id)
    elsif @engagement_form.enrolled_work_program?
      new_work_program_path(engagement_form_id: @engagement_form.id)
    elsif @engagement_form.volunteers_nonprofit?
      new_volunteer_path(engagement_form_id: @engagement_form.id)
    else
      summary_path(@engagement_form.id)
    end
  end
end
