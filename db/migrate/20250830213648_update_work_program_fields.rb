class UpdateWorkProgramFields < ActiveRecord::Migration[8.0]
  def change
    remove_column :engagement_forms, :work_program_details, :text
    add_column :engagement_forms, :work_program_name, :string
    add_column :engagement_forms, :hours_attended, :decimal, precision: 8, scale: 2
  end
end
