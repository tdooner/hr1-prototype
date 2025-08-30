class JobsController < ApplicationController
  def new
    @engagement_form = EngagementForm.find(params[:engagement_form_id])
  end

  def create
    @engagement_form = EngagementForm.find(params[:engagement_form_id])
    
    # Use the new next_path method
    redirect_to next_path(@engagement_form)
  end
  
  # Class method to determine if this controller should be skipped
  def self.skip?(engagement_form)
    !engagement_form.has_job?
  end
end
