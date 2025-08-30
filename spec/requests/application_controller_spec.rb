require 'rails_helper'

RSpec.describe ApplicationController, type: :request do
  # Create a test controller to access the next_path method
  let(:test_controller) do
    Class.new(ApplicationController) do
      def test_next_path(engagement_form, current_controller_class = self.class)
        next_path(engagement_form, current_controller_class)
      end
    end.new
  end

      let(:engagement_form) { EngagementForm.create!(user_name: "Test User", email: "test@example.com") }

  describe '#next_path' do
    context 'when starting from QuestionsController' do
      it 'routes to JobsController when has_job is true' do
        engagement_form.update(has_job: true, is_student: false, enrolled_work_program: false, volunteers_nonprofit: false)
        
        result = test_controller.test_next_path(engagement_form, QuestionsController)
        
        expect(result).to eq("/engagement_forms/#{engagement_form.id}/jobs/new")
      end

      it 'routes to StudentsController when has_job is false but is_student is true' do
        engagement_form.update(has_job: false, is_student: true, enrolled_work_program: false, volunteers_nonprofit: false)
        
        result = test_controller.test_next_path(engagement_form, QuestionsController)
        
        expect(result).to eq("/engagement_forms/#{engagement_form.id}/students/new")
      end

      it 'routes to WorkProgramsController when only enrolled_work_program is true' do
        engagement_form.update(has_job: false, is_student: false, enrolled_work_program: true, volunteers_nonprofit: false)
        
        result = test_controller.test_next_path(engagement_form, QuestionsController)
        
        expect(result).to eq("/engagement_forms/#{engagement_form.id}/work_programs/new")
      end

      it 'routes to VolunteersController when only volunteers_nonprofit is true' do
        engagement_form.update(has_job: false, is_student: false, enrolled_work_program: false, volunteers_nonprofit: true)
        
        result = test_controller.test_next_path(engagement_form, QuestionsController)
        
        expect(result).to eq("/engagement_forms/#{engagement_form.id}/volunteers/new")
      end

      it 'routes to summary when no engagement types are selected' do
        engagement_form.update(has_job: false, is_student: false, enrolled_work_program: false, volunteers_nonprofit: false)
        
        result = test_controller.test_next_path(engagement_form, QuestionsController)
        
        expect(result).to eq("/summary/#{engagement_form.id}/review")
      end
    end

    context 'when starting from JobsController' do
      it 'routes to StudentsController when is_student is true' do
        engagement_form.update(has_job: true, is_student: true, enrolled_work_program: false, volunteers_nonprofit: false)
        
        result = test_controller.test_next_path(engagement_form, JobsController)
        
        expect(result).to eq("/engagement_forms/#{engagement_form.id}/students/new")
      end

      it 'routes to WorkProgramsController when is_student is false but enrolled_work_program is true' do
        engagement_form.update(has_job: true, is_student: false, enrolled_work_program: true, volunteers_nonprofit: false)
        
        result = test_controller.test_next_path(engagement_form, JobsController)
        
        expect(result).to eq("/engagement_forms/#{engagement_form.id}/work_programs/new")
      end

      it 'routes to VolunteersController when only volunteers_nonprofit is true' do
        engagement_form.update(has_job: true, is_student: false, enrolled_work_program: false, volunteers_nonprofit: true)
        
        result = test_controller.test_next_path(engagement_form, JobsController)
        
        expect(result).to eq("/engagement_forms/#{engagement_form.id}/volunteers/new")
      end

      it 'routes to summary when no remaining engagement types are selected' do
        engagement_form.update(has_job: true, is_student: false, enrolled_work_program: false, volunteers_nonprofit: false)
        
        result = test_controller.test_next_path(engagement_form, JobsController)
        
        expect(result).to eq("/summary/#{engagement_form.id}/review")
      end
    end

    context 'when starting from StudentsController' do
      it 'routes to WorkProgramsController when enrolled_work_program is true' do
        engagement_form.update(has_job: true, is_student: true, enrolled_work_program: true, volunteers_nonprofit: false)
        
        result = test_controller.test_next_path(engagement_form, StudentsController)
        
        expect(result).to eq("/engagement_forms/#{engagement_form.id}/work_programs/new")
      end

      it 'routes to VolunteersController when enrolled_work_program is false but volunteers_nonprofit is true' do
        engagement_form.update(has_job: true, is_student: true, enrolled_work_program: false, volunteers_nonprofit: true)
        
        result = test_controller.test_next_path(engagement_form, StudentsController)
        
        expect(result).to eq("/engagement_forms/#{engagement_form.id}/volunteers/new")
      end

      it 'routes to summary when no remaining engagement types are selected' do
        engagement_form.update(has_job: true, is_student: true, enrolled_work_program: false, volunteers_nonprofit: false)
        
        result = test_controller.test_next_path(engagement_form, StudentsController)
        
        expect(result).to eq("/summary/#{engagement_form.id}/review")
      end
    end

    context 'when starting from WorkProgramsController' do
      it 'routes to VolunteersController when volunteers_nonprofit is true' do
        engagement_form.update(has_job: true, is_student: true, enrolled_work_program: true, volunteers_nonprofit: true)
        
        result = test_controller.test_next_path(engagement_form, WorkProgramsController)
        
        expect(result).to eq("/engagement_forms/#{engagement_form.id}/volunteers/new")
      end

      it 'routes to summary when volunteers_nonprofit is false' do
        engagement_form.update(has_job: true, is_student: true, enrolled_work_program: true, volunteers_nonprofit: false)
        
        result = test_controller.test_next_path(engagement_form, WorkProgramsController)
        
        expect(result).to eq("/summary/#{engagement_form.id}/review")
      end
    end

    context 'when starting from VolunteersController' do
      it 'routes to summary since it is the last step' do
        engagement_form.update(has_job: true, is_student: true, enrolled_work_program: true, volunteers_nonprofit: true)
        
        result = test_controller.test_next_path(engagement_form, VolunteersController)
        
        expect(result).to eq("/summary/#{engagement_form.id}/review")
      end
    end

    context 'when controller is not in the order' do
      it 'routes to summary for unknown controller' do
        engagement_form.update(has_job: true, is_student: true, enrolled_work_program: true, volunteers_nonprofit: true)
        
        result = test_controller.test_next_path(engagement_form, ApplicationController)
        
        expect(result).to eq("/summary/#{engagement_form.id}/review")
      end
    end
  end
end
