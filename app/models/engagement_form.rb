class EngagementForm < ApplicationRecord
  validates :user_name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  
  has_many :volunteer_shifts, dependent: :destroy
  has_many :job_paychecks, dependent: :destroy
end
