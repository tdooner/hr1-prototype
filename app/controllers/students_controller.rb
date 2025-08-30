class StudentsController < ApplicationController
  def new
    @engagement_form = EngagementForm.find(params[:engagement_form_id])
  end

  def create
    @engagement_form = EngagementForm.find(params[:engagement_form_id])
    
    # Handle both nested and direct parameters
    student_details = params[:engagement_form]&.dig(:student_details) || params[:student_details]
    @engagement_form.update(student_details: student_details)
    
    # Use the new next_path method
    redirect_to next_path(@engagement_form)
  end
  
  # Class method to determine if this controller should be skipped
  def self.skip?(engagement_form)
    !engagement_form.is_student?
  end
end
