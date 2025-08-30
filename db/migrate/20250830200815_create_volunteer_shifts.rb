class CreateVolunteerShifts < ActiveRecord::Migration[8.0]
  def change
    create_table :volunteer_shifts do |t|
      t.references :engagement_form, null: false, foreign_key: true
      t.string :organization_name
      t.date :shift_date
      t.decimal :hours

      t.timestamps
    end
  end
end
