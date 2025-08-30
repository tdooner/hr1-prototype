class AddEngagementFieldsToEngagementForms < ActiveRecord::Migration[8.0]
  def change
    add_column :engagement_forms, :has_job, :boolean
    add_column :engagement_forms, :is_student, :boolean
    add_column :engagement_forms, :enrolled_work_program, :boolean
    add_column :engagement_forms, :volunteers_nonprofit, :boolean
  end
end
