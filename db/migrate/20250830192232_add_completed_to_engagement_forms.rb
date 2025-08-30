class AddCompletedToEngagementForms < ActiveRecord::Migration[8.0]
  def change
    add_column :engagement_forms, :completed, :boolean
  end
end
