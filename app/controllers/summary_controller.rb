class SummaryController < ApplicationController
  def show
    @engagement_form = current_engagement_form
    
    # If the form is not completed, redirect to the review page
    unless @engagement_form.completed?
      redirect_to review_summary_path
      return
    end
  end

  def review
    @engagement_form = current_engagement_form
  end

  def submit
    @engagement_form = current_engagement_form
    
    # Mark the form as completed
    @engagement_form.update(completed: true)
    
    # Redirect to the final summary page
    redirect_to summary_path
  end
end
