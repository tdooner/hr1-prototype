class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Define the order of controllers in the engagement flow
  CONTROLLER_ORDER = [
    QuestionsController,
    JobsController,
    StudentsController,
    WorkProgramsController,
    VolunteersController
  ].freeze

  # Returns the next path in the engagement flow based on the current controller
  # and the engagement form's state
  def next_path(engagement_form, current_controller_class = self.class)
    current_index = CONTROLLER_ORDER.index(current_controller_class)
    
    # If current controller is not in the order, or we're at the end, go to summary
    return "/summary/#{engagement_form.id}/review" if current_index.nil? || current_index == CONTROLLER_ORDER.length - 1
    
    # Find the next controller that should not be skipped
    next_index = current_index + 1
    while next_index < CONTROLLER_ORDER.length
      next_controller = CONTROLLER_ORDER[next_index]
      unless next_controller.skip?(engagement_form)
        controller_name = next_controller.name.underscore.gsub('_controller', '')
        return "/engagement_forms/#{engagement_form.id}/#{controller_name}/new"
      end
      next_index += 1
    end
    
    # If no next controller found, go to summary
    "/summary/#{engagement_form.id}/review"
  end
end
