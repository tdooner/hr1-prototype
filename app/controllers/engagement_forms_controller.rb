class EngagementFormsController < ApplicationController
  def new
    @engagement_form = EngagementForm.new
  end

  def create
    @engagement_form = EngagementForm.new(engagement_form_params)
    
    if @engagement_form.save
      redirect_to new_engagement_form_question_path(@engagement_form)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @engagement_form = EngagementForm.find(params[:id])

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "community_engagement_#{@engagement_form.id}",
               template: "engagement_forms/show",
               layout: "pdf",
               disposition: "attachment"
      end
    end
  end

  def edit
    @engagement_form = EngagementForm.find(params[:id])
  end

  def update
    @engagement_form = EngagementForm.find(params[:id])
    
    if @engagement_form.update(engagement_form_params)
      redirect_to review_summary_path(@engagement_form), notice: 'Basic information updated successfully!'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def engagement_form_params
    params.require(:engagement_form).permit(:user_name, :email)
  end
end
