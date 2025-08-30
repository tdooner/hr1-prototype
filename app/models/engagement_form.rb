class EngagementForm < ApplicationRecord
  validates :user_name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :application_date, presence: true
  
  has_many :volunteer_shifts, dependent: :destroy
  has_many :job_paychecks, dependent: :destroy
  
  def prior_month
    return nil unless application_date
    application_date.beginning_of_month - 1.month
  end
  
  def prior_month_name
    return nil unless prior_month
    prior_month.strftime("%B %Y")
  end
end
