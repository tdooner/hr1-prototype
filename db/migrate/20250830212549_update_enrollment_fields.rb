class UpdateEnrollmentFields < ActiveRecord::Migration[8.0]
  def change
    remove_column :engagement_forms, :enrolled_half_time, :boolean
    add_column :engagement_forms, :enrollment_status, :string
    add_column :engagement_forms, :school_hours, :decimal, precision: 5, scale: 2
  end
end
