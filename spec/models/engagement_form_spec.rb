require 'rails_helper'

RSpec.describe EngagementForm, type: :model do
  describe '#meets_requirements?' do
    let(:engagement_form) { create(:engagement_form) }

    context 'when enrolled half-time or more' do
      before do
        engagement_form.update!(
          is_student: true,
          enrollment_status: 'half_time_or_more'
        )
      end

      it 'returns true' do
        expect(engagement_form.meets_requirements?).to be true
      end
    end

    context 'when meets income requirement' do
      before do
        engagement_form.update!(has_job: true)
        create(:job_paycheck, 
          engagement_form: engagement_form,
          pay_date: engagement_form.prior_month + 15.days,
          gross_pay_amount: 600.0,
          hours_worked: 40.0
        )
      end

      it 'returns true' do
        expect(engagement_form.meets_requirements?).to be true
      end
    end
  end

  describe '#verification_details' do
    let(:engagement_form) { create(:engagement_form) }

    it 'returns verification details hash' do
      details = engagement_form.verification_details
      
      expect(details).to be_a(Hash)
      expect(details).to include(
        :enrolled_half_time_or_more,
        :income_requirement_met,
        :hours_requirement_met,
        :total_income,
        :total_hours
      )
    end
  end
end
