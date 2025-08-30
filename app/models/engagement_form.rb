class EngagementForm < ApplicationRecord
  validates :user_name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :organization, presence: true
  
  has_many :volunteer_shifts, dependent: :destroy
end
