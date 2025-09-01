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

  let(:engagement_form) { EngagementForm.create!(user_name: "Test User", email: "test@example.com", application_date: Date.current) }

  describe '#next_path' do
    context 'when starting from QuestionsController' do
      it 'routes to JobsController when has_job is true' do
        engagement_form.update(has_job: true, is_student: false, enrolled_work_program: false, volunteers_nonprofit: false)

        result = test_controller.test_next_path(engagement_form, QuestionsController)

        expect(result).to eq("/jobs/new")
      end

      it 'routes to StudentsController when has_job is false but is_student is true' do
        engagement_form.update(has_job: false, is_student: true, enrolled_work_program: false, volunteers_nonprofit: false)

        result = test_controller.test_next_path(engagement_form, QuestionsController)

        expect(result).to eq("/students/new")
      end

      it 'routes to WorkProgramsController when only enrolled_work_program is true' do
        engagement_form.update(has_job: false, is_student: false, enrolled_work_program: true, volunteers_nonprofit: false)

        result = test_controller.test_next_path(engagement_form, QuestionsController)

        expect(result).to eq("/work_programs/new")
      end

      it 'routes to VolunteersController when only volunteers_nonprofit is true' do
        engagement_form.update(has_job: false, is_student: false, enrolled_work_program: false, volunteers_nonprofit: true)

        result = test_controller.test_next_path(engagement_form, QuestionsController)

        expect(result).to eq("/volunteers/new")
      end

      it 'routes to summary when no engagement types are selected' do
        engagement_form.update(has_job: false, is_student: false, enrolled_work_program: false, volunteers_nonprofit: false)

        result = test_controller.test_next_path(engagement_form, QuestionsController)

        expect(result).to eq("/summary/review")
      end
    end

    context 'when starting from JobsController' do
      it 'routes to StudentsController when is_student is true' do
        engagement_form.update(has_job: true, is_student: true, enrolled_work_program: false, volunteers_nonprofit: false)

        result = test_controller.test_next_path(engagement_form, JobsController)

        expect(result).to eq("/students/new")
      end

      it 'routes to WorkProgramsController when only enrolled_work_program is true' do
        engagement_form.update(has_job: true, is_student: false, enrolled_work_program: true, volunteers_nonprofit: false)

        result = test_controller.test_next_path(engagement_form, JobsController)

        expect(result).to eq("/work_programs/new")
      end

      it 'routes to VolunteersController when only volunteers_nonprofit is true' do
        engagement_form.update(has_job: true, is_student: false, enrolled_work_program: false, volunteers_nonprofit: true)

        result = test_controller.test_next_path(engagement_form, JobsController)

        expect(result).to eq("/volunteers/new")
      end

      it 'routes to summary when no more engagement types are selected' do
        engagement_form.update(has_job: true, is_student: false, enrolled_work_program: false, volunteers_nonprofit: false)

        result = test_controller.test_next_path(engagement_form, JobsController)

        expect(result).to eq("/summary/review")
      end
    end

    context 'when starting from VolunteersController (last in order)' do
      it 'routes to summary' do
        engagement_form.update(has_job: true, is_student: true, enrolled_work_program: true, volunteers_nonprofit: true)

        result = test_controller.test_next_path(engagement_form, VolunteersController)

        expect(result).to eq("/summary/review")
      end
    end
  end
end
