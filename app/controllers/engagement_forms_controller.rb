class EngagementFormsController < ApplicationController
  skip_before_action :ensure_engagement_form_session, only: [ :new, :create ]

  def new
    @engagement_form = EngagementForm.new(application_date: Date.current)
  end

  def create
    @engagement_form = EngagementForm.new(engagement_form_params)

    if @engagement_form.save
      set_engagement_form_session(@engagement_form)
      redirect_to new_question_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @engagement_form = current_engagement_form

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
    @engagement_form = current_engagement_form
  end

  def update
    @engagement_form = current_engagement_form

    if @engagement_form.update(engagement_form_params)
      redirect_to review_summary_path, notice: "Basic information updated successfully!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def engagement_form_params
    params.require(:engagement_form).permit(:user_name, :email, :application_date)
  end
end
