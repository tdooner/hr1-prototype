class StudentsController < ApplicationController
  def new
    @engagement_form = EngagementForm.find(params[:engagement_form_id])
  end

  def create
    @engagement_form = EngagementForm.find(params[:engagement_form_id])
    
    # Handle both nested and direct parameters
    school_name = params[:engagement_form]&.dig(:school_name) || params[:school_name]
    enrollment_status = params[:engagement_form]&.dig(:enrollment_status) || params[:enrollment_status]
    school_hours = params[:engagement_form]&.dig(:school_hours) || params[:school_hours]
    
    @engagement_form.update(
      school_name: school_name,
      enrollment_status: enrollment_status,
      school_hours: school_hours
    )
    
    # Use the new next_path method
    redirect_to next_path(@engagement_form)
  end
  
  # Class method to determine if this controller should be skipped
  def self.skip?(engagement_form)
    !engagement_form.is_student?
  end
end
