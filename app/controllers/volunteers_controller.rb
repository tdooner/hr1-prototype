class VolunteersController < ApplicationController
  def new
    @engagement_form = EngagementForm.find(params[:engagement_form_id])
  end

  def create
    @engagement_form = EngagementForm.find(params[:engagement_form_id])
    
    @engagement_form.update(volunteer_details: params[:volunteer_details])
    
    # Go to summary since this is the last step
    redirect_to summary_path(@engagement_form.id)
  end
end
