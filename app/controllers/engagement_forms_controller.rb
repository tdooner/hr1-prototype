class EngagementFormsController < ApplicationController
  def new
    @engagement_form = EngagementForm.new
  end

  def create
    @engagement_form = EngagementForm.new(engagement_form_params)
    
    if @engagement_form.save
      redirect_to @engagement_form, notice: 'Community engagement form submitted successfully!'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @engagement_form = EngagementForm.find(params[:id])
  end

  def pdf
    @engagement_form = EngagementForm.find(params[:id])
    
    respond_to do |format|
      format.pdf do
        render pdf: "community_engagement_#{@engagement_form.id}",
               template: "engagement_forms/pdf",
               layout: "pdf",
               disposition: "attachment"
      end
    end
  end

  private

  def engagement_form_params
    params.require(:engagement_form).permit(:user_name, :email, :organization)
  end
end
