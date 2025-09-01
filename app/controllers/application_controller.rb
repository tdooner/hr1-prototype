class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Define the order of controllers in the engagement flow
  CONTROLLER_ORDER = [
    "QuestionsController",
    "JobsController",
    "StudentsController",
    "WorkProgramsController",
    "VolunteersController"
  ].freeze

  before_action :ensure_engagement_form_session

  # Returns the next path in the engagement flow based on the current controller
  # and the engagement form's state
  def next_path(engagement_form, current_controller_class = self.class)
    current_controller_name = current_controller_class.name
    current_index = CONTROLLER_ORDER.index(current_controller_name)

    # If current controller is not in the order, or we're at the end, go to summary
    return "/summary/review" if current_index.nil? || current_index == CONTROLLER_ORDER.length - 1

    # Find the next controller that should not be skipped
    next_index = current_index + 1
    while next_index < CONTROLLER_ORDER.length
      next_controller_name = CONTROLLER_ORDER[next_index]
      next_controller_class = next_controller_name.constantize
      unless next_controller_class.skip?(engagement_form)
        controller_name = next_controller_name.underscore.gsub("_controller", "")
        return "/#{controller_name}/new"
      end
      next_index += 1
    end

    # If no next controller found, go to summary
    "/summary/review"
  end

  private

  def ensure_engagement_form_session
    # Only check for engagement form session on pages that need it
    return if controller_name == "engagement_forms" && action_name == "new"
    return if controller_name == "engagement_forms" && action_name == "create"

    unless session[:engagement_form_id]
      redirect_to new_engagement_form_path, alert: "Please start a new engagement form."
    end
  end

  def current_engagement_form
    @current_engagement_form ||= EngagementForm.find(session[:engagement_form_id]) if session[:engagement_form_id]
  end

  def set_engagement_form_session(engagement_form)
    session[:engagement_form_id] = engagement_form.id
  end

  def clear_engagement_form_session
    session.delete(:engagement_form_id)
  end
end
