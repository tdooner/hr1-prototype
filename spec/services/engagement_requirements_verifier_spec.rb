require 'rails_helper'

RSpec.describe EngagementRequirementsVerifier do
  let(:application_date) { Date.new(2024, 2, 15) }
  let(:prior_month) { Date.new(2024, 1, 1) }
  let(:engagement_form) { create(:engagement_form, application_date: application_date) }
  let(:verifier) { described_class.new(engagement_form) }

  describe '#meets_requirements?' do
    context 'when no application date is set' do
      let(:engagement_form) { build(:engagement_form, :without_application_date) }

      it 'returns false' do
        expect(verifier.meets_requirements?).to be false
      end
    end

    context 'when enrolled half-time or more in school' do
      before do
        engagement_form.update!(
          is_student: true,
          enrollment_status: 'half_time_or_more'
        )
      end

      it 'returns true' do
        expect(verifier.meets_requirements?).to be true
      end

      it 'returns true even with no other activities' do
        expect(verifier.meets_requirements?).to be true
      end
    end

    context 'when meets income requirement' do
      before do
        engagement_form.update!(has_job: true)
        create(:job_paycheck,
          engagement_form: engagement_form,
          pay_date: prior_month + 15.days,
          gross_pay_amount: 600.0,
          hours_worked: 40.0
        )
      end

      it 'returns true' do
        expect(verifier.meets_requirements?).to be true
      end
    end

    context 'when meets hours requirement' do
      before do
        engagement_form.update!(has_job: true)
        create(:job_paycheck,
          engagement_form: engagement_form,
          pay_date: prior_month + 15.days,
          gross_pay_amount: 400.0,
          hours_worked: 80.0
        )
      end

      it 'returns true' do
        expect(verifier.meets_requirements?).to be true
      end
    end

    context 'when combining multiple activities to meet hours requirement' do
      before do
        engagement_form.update!(
          has_job: true,
          is_student: true,
          enrolled_work_program: true,
          volunteers_nonprofit: true,
          enrollment_status: 'less_than_half_time',
          school_hours: 20.0,
          hours_attended: 20.0
        )

        create(:job_paycheck,
          engagement_form: engagement_form,
          pay_date: prior_month + 15.days,
          gross_pay_amount: 300.0,
          hours_worked: 20.0
        )

        create(:volunteer_shift,
          engagement_form: engagement_form,
          shift_date: prior_month + 10.days,
          hours: 20.0
        )
      end

      it 'returns true' do
        expect(verifier.meets_requirements?).to be true
      end
    end

    context 'when none of the requirements are met' do
      before do
        engagement_form.update!(
          has_job: true,
          is_student: true,
          enrollment_status: 'less_than_half_time',
          school_hours: 10.0
        )

        create(:job_paycheck,
          engagement_form: engagement_form,
          pay_date: prior_month + 15.days,
          gross_pay_amount: 300.0,
          hours_worked: 20.0
        )
      end

      it 'returns false' do
        expect(verifier.meets_requirements?).to be false
      end
    end
  end

  describe '#verification_details' do
    before do
      engagement_form.update!(
        has_job: true,
        is_student: true,
        enrolled_work_program: true,
        volunteers_nonprofit: true,
        enrollment_status: 'less_than_half_time',
        school_hours: 20.0,
        hours_attended: 20.0
      )

      create(:job_paycheck,
        engagement_form: engagement_form,
        pay_date: prior_month + 15.days,
        gross_pay_amount: 600.0,
        hours_worked: 20.0
      )

      create(:volunteer_shift,
        engagement_form: engagement_form,
        shift_date: prior_month + 10.days,
        hours: 20.0
      )
    end

    it 'returns detailed verification information' do
      details = verifier.verification_details

      expect(details).to include(
        enrolled_half_time_or_more: false,
        income_requirement_met: true,
        hours_requirement_met: true,
        total_income: 600.0,
        total_hours: 80.0,
        school_hours: 20.0,
        work_hours: 20.0,
        work_program_hours: 20.0,
        volunteer_hours: 20.0,
        unused_data: {}
      )
    end
  end

  describe 'income requirement calculations' do
    context 'when no job' do
      before do
        engagement_form.update!(has_job: false)
      end

      it 'returns 0 income' do
        expect(verifier.send(:calculate_total_income)).to eq(0.0)
      end
    end

    context 'when has job but no paychecks in prior month' do
      before do
        engagement_form.update!(has_job: true)
        create(:job_paycheck,
          engagement_form: engagement_form,
          pay_date: prior_month - 1.month,
          gross_pay_amount: 600.0,
          hours_worked: 40.0
        )
      end

      it 'returns 0 income' do
        expect(verifier.send(:calculate_total_income)).to eq(0.0)
      end
    end

    context 'when has multiple paychecks in prior month' do
      before do
        engagement_form.update!(has_job: true)
        create(:job_paycheck,
          engagement_form: engagement_form,
          pay_date: prior_month + 15.days,
          gross_pay_amount: 300.0,
          hours_worked: 20.0
        )
        create(:job_paycheck,
          engagement_form: engagement_form,
          pay_date: prior_month + 30.days,
          gross_pay_amount: 400.0,
          hours_worked: 25.0
        )
      end

      it 'sums all paychecks in prior month' do
        expect(verifier.send(:calculate_total_income)).to eq(700.0)
      end
    end

    context 'when income is exactly at minimum' do
      before do
        engagement_form.update!(has_job: true)
        create(:job_paycheck,
          engagement_form: engagement_form,
          pay_date: prior_month + 15.days,
          gross_pay_amount: 580.0,
          hours_worked: 40.0
        )
      end

      it 'meets income requirement' do
        expect(verifier.send(:meets_income_requirement?)).to be true
      end
    end

    context 'when income is below minimum' do
      before do
        engagement_form.update!(has_job: true)
        create(:job_paycheck,
          engagement_form: engagement_form,
          pay_date: prior_month + 15.days,
          gross_pay_amount: 579.0,
          hours_worked: 40.0
        )
      end

      it 'does not meet income requirement' do
        expect(verifier.send(:meets_income_requirement?)).to be false
      end
    end
  end

  describe 'hours requirement calculations' do
    context 'when no activities' do
      it 'returns 0 total hours' do
        expect(verifier.send(:calculate_total_hours)).to eq(0.0)
      end
    end

    context 'when has job hours' do
      before do
        engagement_form.update!(has_job: true)
        create(:job_paycheck,
          engagement_form: engagement_form,
          pay_date: prior_month + 15.days,
          gross_pay_amount: 400.0,
          hours_worked: 40.0
        )
      end

      it 'includes work hours in total' do
        expect(verifier.send(:calculate_total_hours)).to eq(40.0)
      end
    end

    context 'when enrolled half-time or more' do
      before do
        engagement_form.update!(
          is_student: true,
          enrollment_status: 'half_time_or_more'
        )
      end

      it 'does not count school hours toward total' do
        expect(verifier.send(:calculate_school_hours)).to eq(0.0)
      end
    end

    context 'when enrolled less than half-time' do
      before do
        engagement_form.update!(
          is_student: true,
          enrollment_status: 'less_than_half_time',
          school_hours: 25.0
        )
      end

      it 'counts school hours toward total' do
        expect(verifier.send(:calculate_school_hours)).to eq(25.0)
      end
    end

    context 'when enrolled less than half-time but no school hours' do
      before do
        engagement_form.update!(
          is_student: true,
          enrollment_status: 'less_than_half_time',
          school_hours: nil
        )
      end

      it 'returns 0 school hours' do
        expect(verifier.send(:calculate_school_hours)).to eq(0.0)
      end
    end

    context 'when enrolled in work program' do
      before do
        engagement_form.update!(
          enrolled_work_program: true,
          hours_attended: 30.0
        )
      end

      it 'includes work program hours in total' do
        expect(verifier.send(:calculate_total_hours)).to eq(30.0)
      end
    end

    context 'when volunteers' do
      before do
        engagement_form.update!(volunteers_nonprofit: true)
        create(:volunteer_shift,
          engagement_form: engagement_form,
          shift_date: prior_month + 10.days,
          hours: 15.0
        )
        create(:volunteer_shift,
          engagement_form: engagement_form,
          shift_date: prior_month + 20.days,
          hours: 10.0
        )
      end

      it 'includes volunteer hours in total' do
        expect(verifier.send(:calculate_total_hours)).to eq(25.0)
      end
    end

    context 'when combining all activities' do
      before do
        engagement_form.update!(
          has_job: true,
          is_student: true,
          enrolled_work_program: true,
          volunteers_nonprofit: true,
          enrollment_status: 'less_than_half_time',
          school_hours: 10.0,
          hours_attended: 15.0
        )

        create(:job_paycheck,
          engagement_form: engagement_form,
          pay_date: prior_month + 15.days,
          gross_pay_amount: 400.0,
          hours_worked: 25.0
        )

        create(:volunteer_shift,
          engagement_form: engagement_form,
          shift_date: prior_month + 10.days,
          hours: 30.0
        )
      end

      it 'sums all hours correctly' do
        expect(verifier.send(:calculate_total_hours)).to eq(80.0)
      end
    end

    context 'when hours are exactly at minimum' do
      before do
        engagement_form.update!(has_job: true)
        create(:job_paycheck,
          engagement_form: engagement_form,
          pay_date: prior_month + 15.days,
          gross_pay_amount: 400.0,
          hours_worked: 80.0
        )
      end

      it 'meets hours requirement' do
        expect(verifier.send(:meets_hours_requirement?)).to be true
      end
    end

    context 'when hours are below minimum' do
      before do
        engagement_form.update!(has_job: true)
        create(:job_paycheck,
          engagement_form: engagement_form,
          pay_date: prior_month + 15.days,
          gross_pay_amount: 400.0,
          hours_worked: 79.0
        )
      end

      it 'does not meet hours requirement' do
        expect(verifier.send(:meets_hours_requirement?)).to be false
      end
    end
  end

  describe 'enrollment status verification' do
    context 'when not a student' do
      before do
        engagement_form.update!(is_student: false)
      end

      it 'returns false for half-time enrollment' do
        expect(verifier.send(:enrolled_half_time_or_more?)).to be false
      end
    end

    context 'when is student but enrollment status is nil' do
      before do
        engagement_form.update!(
          is_student: true,
          enrollment_status: nil
        )
      end

      it 'returns false for half-time enrollment' do
        expect(verifier.send(:enrolled_half_time_or_more?)).to be false
      end
    end

    context 'when is student but enrolled less than half-time' do
      before do
        engagement_form.update!(
          is_student: true,
          enrollment_status: 'less_than_half_time'
        )
      end

      it 'returns false for half-time enrollment' do
        expect(verifier.send(:enrolled_half_time_or_more?)).to be false
      end
    end

    context 'when is student and enrolled half-time or more' do
      before do
        engagement_form.update!(
          is_student: true,
          enrollment_status: 'half_time_or_more'
        )
      end

      it 'returns true for half-time enrollment' do
        expect(verifier.send(:enrolled_half_time_or_more?)).to be true
      end
    end
  end

  describe 'unused data tracking' do
    context 'when job paychecks are outside prior month' do
      before do
        engagement_form.update!(has_job: true)
        create(:job_paycheck,
          engagement_form: engagement_form,
          pay_date: prior_month - 1.month,
          gross_pay_amount: 1000.0,
          hours_worked: 100.0
        )
        create(:job_paycheck,
          engagement_form: engagement_form,
          pay_date: prior_month + 2.months,
          gross_pay_amount: 800.0,
          hours_worked: 80.0
        )
      end

      it 'tracks unused paychecks in verification details' do
        details = verifier.verification_details
        unused_data = details[:unused_data]

        expect(unused_data).to have_key(:job_paychecks)
        expect(unused_data[:job_paychecks][:count]).to eq(2)
        expect(unused_data[:job_paychecks][:total_income]).to eq(1800.0)
        expect(unused_data[:job_paychecks][:total_hours]).to eq(180.0)
        expect(unused_data[:job_paychecks][:months]).to include(
          (prior_month - 1.month).strftime("%B %Y"),
          (prior_month + 2.months).strftime("%B %Y")
        )
      end
    end

    context 'when volunteer shifts are outside prior month' do
      before do
        engagement_form.update!(volunteers_nonprofit: true)
        create(:volunteer_shift,
          engagement_form: engagement_form,
          shift_date: prior_month - 1.month,
          hours: 100.0
        )
        create(:volunteer_shift,
          engagement_form: engagement_form,
          shift_date: prior_month + 2.months,
          hours: 50.0
        )
      end

      it 'tracks unused volunteer shifts in verification details' do
        details = verifier.verification_details
        unused_data = details[:unused_data]

        expect(unused_data).to have_key(:volunteer_shifts)
        expect(unused_data[:volunteer_shifts][:count]).to eq(2)
        expect(unused_data[:volunteer_shifts][:total_hours]).to eq(150.0)
        expect(unused_data[:volunteer_shifts][:months]).to include(
          (prior_month - 1.month).strftime("%B %Y"),
          (prior_month + 2.months).strftime("%B %Y")
        )
      end
    end

    context 'when no data is outside prior month' do
      before do
        engagement_form.update!(has_job: true, volunteers_nonprofit: true)
        create(:job_paycheck,
          engagement_form: engagement_form,
          pay_date: prior_month + 15.days,
          gross_pay_amount: 600.0,
          hours_worked: 40.0
        )
        create(:volunteer_shift,
          engagement_form: engagement_form,
          shift_date: prior_month + 10.days,
          hours: 20.0
        )
      end

      it 'returns empty unused data hash' do
        details = verifier.verification_details
        expect(details[:unused_data]).to eq({})
      end
    end
  end

  describe 'edge cases' do
    context 'when volunteer shifts are outside prior month' do
      before do
        engagement_form.update!(volunteers_nonprofit: true)
        create(:volunteer_shift,
          engagement_form: engagement_form,
          shift_date: prior_month - 1.month,
          hours: 100.0
        )
      end

      it 'does not include volunteer hours from other months' do
        expect(verifier.send(:calculate_volunteer_hours)).to eq(0.0)
      end
    end

    context 'when job paychecks are outside prior month' do
      before do
        engagement_form.update!(has_job: true)
        create(:job_paycheck,
          engagement_form: engagement_form,
          pay_date: prior_month + 2.months,
          gross_pay_amount: 1000.0,
          hours_worked: 100.0
        )
      end

      it 'does not include paychecks from other months' do
        expect(verifier.send(:calculate_total_income)).to eq(0.0)
        expect(verifier.send(:calculate_work_hours)).to eq(0.0)
      end
    end

    context 'when work program hours are nil' do
      before do
        engagement_form.update!(
          enrolled_work_program: true,
          hours_attended: nil
        )
      end

      it 'returns 0 work program hours' do
        expect(verifier.send(:calculate_work_program_hours)).to eq(0.0)
      end
    end
  end
end
