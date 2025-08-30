class CreateJobPaychecks < ActiveRecord::Migration[8.0]
  def change
    create_table :job_paychecks do |t|
      t.references :engagement_form, null: false, foreign_key: true
      t.date :pay_date
      t.decimal :gross_pay_amount
      t.decimal :hours_worked

      t.timestamps
    end
  end
end
