class AddDetailFieldsToEngagementForms < ActiveRecord::Migration[8.0]
  def change
    add_column :engagement_forms, :job_details, :text
    add_column :engagement_forms, :student_details, :text
    add_column :engagement_forms, :work_program_details, :text
    add_column :engagement_forms, :volunteer_details, :text
  end
end
