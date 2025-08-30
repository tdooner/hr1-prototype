class RemoveJobDetailsFromEngagementForms < ActiveRecord::Migration[8.0]
  def change
    remove_column :engagement_forms, :job_details, :text
  end
end
