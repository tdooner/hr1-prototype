class VolunteerShiftsController < ApplicationController
  def new
    @engagement_form = current_engagement_form
    @volunteer_shift = @engagement_form.volunteer_shifts.build
  end

  def create
    @engagement_form = current_engagement_form
    @volunteer_shift = @engagement_form.volunteer_shifts.build(volunteer_shift_params)

    if @volunteer_shift.save
      redirect_to new_volunteer_path, notice: "Volunteer shift was successfully added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def volunteer_shift_params
    params.require(:volunteer_shift).permit(:organization_name, :shift_date, :hours)
  end
end
