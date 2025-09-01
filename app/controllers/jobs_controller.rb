class JobsController < ApplicationController
  def new
    @engagement_form = current_engagement_form
  end

  def create
    @engagement_form = current_engagement_form

    # Check if user came from review page
    if params[:from_review] == "true"
      redirect_to review_summary_path
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
