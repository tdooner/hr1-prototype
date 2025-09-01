class EngagementRequirementsVerifier
  MINIMUM_MONTHLY_INCOME = 580.0
  MINIMUM_TOTAL_HOURS = 80.0

  def initialize(engagement_form)
    @engagement_form = engagement_form
    @prior_month = engagement_form.prior_month
  end

  def meets_requirements?
    return false unless @prior_month

    enrolled_half_time_or_more? ||
    meets_income_requirement? ||
    meets_hours_requirement?
  end

  def verification_details
    {
      enrolled_half_time_or_more: enrolled_half_time_or_more?,
      income_requirement_met: meets_income_requirement?,
      hours_requirement_met: meets_hours_requirement?,
      total_income: calculate_total_income,
      total_hours: calculate_total_hours,
      school_hours: calculate_school_hours,
      work_hours: calculate_work_hours,
      work_program_hours: calculate_work_program_hours,
      volunteer_hours: calculate_volunteer_hours,
      unused_data: calculate_unused_data
    }
  end

  private

  def enrolled_half_time_or_more?
    return false unless @engagement_form.is_student?
    return false unless @engagement_form.enrollment_status == "half_time_or_more"
    true
  end

  def meets_income_requirement?
    calculate_total_income >= MINIMUM_MONTHLY_INCOME
  end

  def meets_hours_requirement?
    calculate_total_hours >= MINIMUM_TOTAL_HOURS
  end

  def calculate_total_income
    return 0.0 unless @engagement_form.has_job?

    @engagement_form.job_paychecks
      .where("DATE_TRUNC('month', pay_date) = ?", @prior_month.beginning_of_month)
      .sum(:gross_pay_amount)
  end

  def calculate_total_hours
    calculate_work_hours + calculate_school_hours + calculate_work_program_hours + calculate_volunteer_hours
  end

  def calculate_work_hours
    return 0.0 unless @engagement_form.has_job?

    @engagement_form.job_paychecks
      .where("DATE_TRUNC('month', pay_date) = ?", @prior_month.beginning_of_month)
      .sum(:hours_worked)
  end

  def calculate_school_hours
    return 0.0 unless @engagement_form.is_student?

    # If enrolled half-time or more, school hours don't count toward the 80-hour requirement
    return 0.0 if @engagement_form.enrollment_status == "half_time_or_more"

    # If enrolled less than half-time, use the school_hours field
    @engagement_form.school_hours || 0.0
  end

  def calculate_work_program_hours
    return 0.0 unless @engagement_form.enrolled_work_program?

    # Use the hours_attended field for work programs
    @engagement_form.hours_attended || 0.0
  end

  def calculate_volunteer_hours
    return 0.0 unless @engagement_form.volunteers_nonprofit?

    @engagement_form.volunteer_shifts
      .where("DATE_TRUNC('month', shift_date) = ?", @prior_month.beginning_of_month)
      .sum(:hours)
  end

  def calculate_unused_data
    unused_data = {}

    # Calculate unused job paychecks
    if @engagement_form.has_job? && @engagement_form.job_paychecks.any?
      unused_paychecks = @engagement_form.job_paychecks
        .where.not("DATE_TRUNC('month', pay_date) = ?", @prior_month.beginning_of_month)

      if unused_paychecks.any?
        unused_data[:job_paychecks] = {
          count: unused_paychecks.count,
          total_income: unused_paychecks.sum(:gross_pay_amount),
          total_hours: unused_paychecks.sum(:hours_worked),
          months: unused_paychecks.group("DATE_TRUNC('month', pay_date)").count.keys.map { |date| date.strftime("%B %Y") }
        }
      end
    end

    # Calculate unused volunteer shifts
    if @engagement_form.volunteers_nonprofit? && @engagement_form.volunteer_shifts.any?
      unused_shifts = @engagement_form.volunteer_shifts
        .where.not("DATE_TRUNC('month', shift_date) = ?", @prior_month.beginning_of_month)

      if unused_shifts.any?
        unused_data[:volunteer_shifts] = {
          count: unused_shifts.count,
          total_hours: unused_shifts.sum(:hours),
          months: unused_shifts.group("DATE_TRUNC('month', shift_date)").count.keys.map { |date| date.strftime("%B %Y") }
        }
      end
    end

    unused_data
  end
end
