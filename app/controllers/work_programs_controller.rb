class WorkProgramsController < ApplicationController
  def new
    @engagement_form = EngagementForm.find(params[:engagement_form_id])
  end

  def create
    @engagement_form = EngagementForm.find(params[:engagement_form_id])
    
    @engagement_form.update(work_program_details: params[:work_program_details])
    
    # Determine next step based on remaining engagement types
    next_step = determine_next_step
    
    redirect_to next_step
  end
  
  private
  
  def determine_next_step
    if @engagement_form.volunteers_nonprofit?
      new_volunteer_path(engagement_form_id: @engagement_form.id)
    else
      summary_path(@engagement_form.id)
    end
  end
end
