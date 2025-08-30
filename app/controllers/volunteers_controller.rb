class VolunteersController < ApplicationController
  def new
    @engagement_form = EngagementForm.find(params[:engagement_form_id])
  end

  def create
    @engagement_form = EngagementForm.find(params[:engagement_form_id])
    
    # Handle both nested and direct parameters
    volunteer_details = params[:engagement_form]&.dig(:volunteer_details) || params[:volunteer_details]
    @engagement_form.update(volunteer_details: volunteer_details)
    
    # Go to review page since this is the last step
    redirect_to review_summary_path(@engagement_form.id)
  end
  
  # Class method to determine if this controller should be skipped
  def self.skip?(engagement_form)
    !engagement_form.volunteers_nonprofit?
  end
end
