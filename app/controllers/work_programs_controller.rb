class WorkProgramsController < ApplicationController
  def new
    @engagement_form = EngagementForm.find(params[:engagement_form_id])
  end

  def create
    @engagement_form = EngagementForm.find(params[:engagement_form_id])
    
    # Handle both nested and direct parameters
    work_program_params = params[:engagement_form]&.permit(:work_program_name, :hours_attended) || 
                         params.permit(:work_program_name, :hours_attended)
    @engagement_form.update(work_program_params)
    
    # Use the new next_path method
    redirect_to next_path(@engagement_form)
  end
  
  # Class method to determine if this controller should be skipped
  def self.skip?(engagement_form)
    !engagement_form.enrolled_work_program?
  end
end
