class SummaryController < ApplicationController
  def show
    @engagement_form = EngagementForm.find(params[:engagement_form_id])
    
    # If the form is not completed, redirect to the review page
    unless @engagement_form.completed?
      redirect_to review_summary_path(@engagement_form)
      return
    end
  end

  def review
    @engagement_form = EngagementForm.find(params[:engagement_form_id])
  end

  def submit
    @engagement_form = EngagementForm.find(params[:engagement_form_id])
    
    # Mark the form as completed
    @engagement_form.update(completed: true)
    
    # Redirect to the final summary page
    redirect_to summary_path(@engagement_form)
  end
end
