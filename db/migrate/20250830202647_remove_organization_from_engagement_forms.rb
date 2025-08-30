class RemoveOrganizationFromEngagementForms < ActiveRecord::Migration[8.0]
  def change
    remove_column :engagement_forms, :organization, :string
  end
end
