class CreateEngagementForms < ActiveRecord::Migration[8.0]
  def change
    create_table :engagement_forms do |t|
      t.string :user_name
      t.string :email
      t.string :organization

      t.timestamps
    end
  end
end
