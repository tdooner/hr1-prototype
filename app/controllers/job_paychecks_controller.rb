class JobPaychecksController < ApplicationController
  def new
    @engagement_form = EngagementForm.find(params[:engagement_form_id])
    @job_paycheck = @engagement_form.job_paychecks.build
  end

  def create
    @engagement_form = EngagementForm.find(params[:engagement_form_id])
    @job_paycheck = @engagement_form.job_paychecks.build(job_paycheck_params)

    if @job_paycheck.save
      redirect_to new_engagement_form_job_path(@engagement_form), notice: "Paycheck added successfully!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def job_paycheck_params
    params.require(:job_paycheck).permit(:pay_date, :gross_pay_amount, :hours_worked)
  end
end
