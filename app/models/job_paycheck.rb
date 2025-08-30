class JobPaycheck < ApplicationRecord
  belongs_to :engagement_form

  validates :pay_date, presence: true
  validates :gross_pay_amount, presence: true, numericality: { greater_than: 0 }
  validates :hours_worked, presence: true, numericality: { greater_than: 0 }

  scope :ordered_by_date, -> { order(pay_date: :desc) }
end
