class AddApplicationDateToEngagementForms < ActiveRecord::Migration[8.0]
  def change
    add_column :engagement_forms, :application_date, :date
  end
end
