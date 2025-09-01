class VolunteersController < ApplicationController
  def new
    @engagement_form = current_engagement_form
    @volunteer_shifts = @engagement_form.volunteer_shifts.ordered_by_date
  end

  def create
    @engagement_form = current_engagement_form

    # Check if user came from review page
    if params[:from_review] == "true"
      redirect_to review_summary_path
    else
      # Go to review page since this is the last step
      redirect_to review_summary_path
    end
  end

  # Class method to determine if this controller should be skipped
  def self.skip?(engagement_form)
    !engagement_form.volunteers_nonprofit?
  end
end
