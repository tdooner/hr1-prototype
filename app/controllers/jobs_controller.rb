class JobsController < ApplicationController
  def new
    @engagement_form = EngagementForm.find(params[:engagement_form_id])
  end

  def create
    @engagement_form = EngagementForm.find(params[:engagement_form_id])
    
    # Handle both nested and direct parameters
    job_details = params[:engagement_form]&.dig(:job_details) || params[:job_details]
    @engagement_form.update(job_details: job_details)
    
    # Determine next step based on remaining engagement types
    next_step = determine_next_step
    
    redirect_to next_step
  end
  
  private
  
  def determine_next_step
    if @engagement_form.is_student?
      new_engagement_form_student_path(@engagement_form)
    elsif @engagement_form.enrolled_work_program?
      new_engagement_form_work_program_path(@engagement_form)
    elsif @engagement_form.volunteers_nonprofit?
      new_engagement_form_volunteer_path(@engagement_form)
    else
      review_summary_path(@engagement_form.id)
    end
  end
end
