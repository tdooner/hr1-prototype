class VolunteerShiftsController < ApplicationController
  def new
    @engagement_form = EngagementForm.find(params[:engagement_form_id])
    @volunteer_shift = @engagement_form.volunteer_shifts.build
  end

  def create
    @engagement_form = EngagementForm.find(params[:engagement_form_id])
    @volunteer_shift = @engagement_form.volunteer_shifts.build(volunteer_shift_params)
    
    if @volunteer_shift.save
      redirect_to new_engagement_form_volunteer_path(@engagement_form), notice: 'Volunteer shift was successfully added.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def volunteer_shift_params
    params.require(:volunteer_shift).permit(:organization_name, :shift_date, :hours)
  end
end
