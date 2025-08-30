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
    
    # Update the attributes
    @engagement_form.assign_attributes(
      school_name: school_name,
      enrollment_status: enrollment_status,
      school_hours: school_hours
    )
    
    # Validate with the students_page context
    if @engagement_form.valid?(:students_page)
      @engagement_form.save!
      # Check if user came from review page
      if params[:from_review] == "true"
        redirect_to review_summary_path(@engagement_form)
      else
        # Use the new next_path method
        redirect_to next_path(@engagement_form)
      end
    else
      # Re-render the form with validation errors
      render :new, status: :unprocessable_entity
    end
  end
  
  # Class method to determine if this controller should be skipped
  def self.skip?(engagement_form)
    !engagement_form.is_student?
  end
end
