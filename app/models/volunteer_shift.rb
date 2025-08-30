class VolunteerShift < ApplicationRecord
  belongs_to :engagement_form
  
  validates :organization_name, presence: true
  validates :shift_date, presence: true
  validates :hours, presence: true, numericality: { greater_than: 0 }
  
  scope :ordered_by_date, -> { order(shift_date: :desc) }
end
