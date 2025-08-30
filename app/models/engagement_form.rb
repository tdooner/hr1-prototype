class EngagementForm < ApplicationRecord
  validates :user_name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :application_date, presence: true
  
  # Student-specific validations
  validates :school_name, presence: true, on: :students_page
  validates :enrollment_status, presence: true, on: :students_page
  validate :school_hours_required_when_less_than_half_time, on: :students_page
  
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
  
  private
  
  def school_hours_required_when_less_than_half_time
    if enrollment_status == "less_than_half_time" && school_hours.blank?
      errors.add(:school_hours, "is required when enrolled less than half-time")
    end
  end
end
