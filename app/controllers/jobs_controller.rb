class JobsController < ApplicationController
  def new
    @engagement_form = EngagementForm.find(params[:engagement_form_id])
  end

  def create
    @engagement_form = EngagementForm.find(params[:engagement_form_id])
    
    # Check if user came from review page
    if params[:from_review] == "true"
      redirect_to review_summary_path(@engagement_form)
    else
      # Use the new next_path method
      redirect_to next_path(@engagement_form)
    end
  end
  
  # Class method to determine if this controller should be skipped
  def self.skip?(engagement_form)
    !engagement_form.has_job?
  end
end
