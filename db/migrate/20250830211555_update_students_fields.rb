class UpdateStudentsFields < ActiveRecord::Migration[8.0]
  def change
    remove_column :engagement_forms, :student_details, :text
    add_column :engagement_forms, :school_name, :string
    add_column :engagement_forms, :enrolled_half_time, :boolean
  end
end
