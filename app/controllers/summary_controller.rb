class SummaryController < ApplicationController
  def show
    @engagement_form = EngagementForm.find(params[:engagement_form_id])
  end
end
