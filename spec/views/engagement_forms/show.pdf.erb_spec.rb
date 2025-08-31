require 'rails_helper'

RSpec.describe "engagement_forms/show.pdf.erb", type: :view do
  
  let(:application_date) { Date.new(2024, 2, 15) }
  let(:prior_month) { Date.new(2024, 1, 1) }
  let(:engagement_form) { create(:engagement_form, application_date: application_date) }
  
  before do
    assign(:engagement_form, engagement_form)
  end

  describe "PDF rendering" do
    context "when user meets requirements through school enrollment" do
      before do
        engagement_form.update!(
          is_student: true,
          enrollment_status: 'half_time_or_more'
        )
      end

      it "renders successfully" do
        expect { render template: "engagement_forms/show", formats: [:pdf] }.not_to raise_error
      end

      it "includes success alert" do
        render template: "engagement_forms/show", formats: [:pdf]
        expect(rendered).to include("Requirements Met")
        expect(rendered).to include("Enrolled at least half-time in school")
      end
    end

    context "when user meets requirements through income" do
      before do
        engagement_form.update!(has_job: true)
        create(:job_paycheck, 
          engagement_form: engagement_form,
          pay_date: prior_month + 15.days,
          gross_pay_amount: 600.0,
          hours_worked: 40.0
        )
      end

      it "renders successfully" do
        expect { render template: "engagement_forms/show", formats: [:pdf] }.not_to raise_error
      end

      it "includes success alert with income details" do
        render template: "engagement_forms/show", formats: [:pdf]
        expect(rendered).to include("Requirements Met")
        expect(rendered).to include("Gross monthly income")
      end
    end

    context "when user meets requirements through hours" do
      before do
        engagement_form.update!(has_job: true)
        create(:job_paycheck, 
          engagement_form: engagement_form,
          pay_date: prior_month + 15.days,
          gross_pay_amount: 400.0,
          hours_worked: 80.0
        )
      end

      it "renders successfully" do
        expect { render template: "engagement_forms/show", formats: [:pdf] }.not_to raise_error
      end

      it "includes success alert with hours details" do
        render template: "engagement_forms/show", formats: [:pdf]
        expect(rendered).to include("Requirements Met")
        expect(rendered).to include("Total of 80 hours")
      end
    end

    context "when user does not meet requirements" do
      before do
        engagement_form.update!(
          has_job: true,
          is_student: false
        )
      end

      it "renders successfully" do
        expect { render template: "engagement_forms/show", formats: [:pdf] }.not_to raise_error
      end

      it "includes warning alert" do
        render template: "engagement_forms/show", formats: [:pdf]
        expect(rendered).to include("Requirements Not Met")
        expect(rendered).to include("does not meet Community Engagement Requirements")
      end
    end

    context "when user has unused data" do
      before do
        engagement_form.update!(has_job: true, volunteers_nonprofit: true)
        create(:job_paycheck, 
          engagement_form: engagement_form,
          pay_date: prior_month - 1.month,
          gross_pay_amount: 800.0,
          hours_worked: 40.0
        )
        create(:volunteer_shift,
          engagement_form: engagement_form,
          shift_date: prior_month - 2.months,
          hours: 20.0
        )
      end

      it "renders successfully" do
        expect { render template: "engagement_forms/show", formats: [:pdf] }.not_to raise_error
      end

      it "includes unused data alert" do
        render template: "engagement_forms/show", formats: [:pdf]
        expect(rendered).to include("Data Not Used for Verification")
        expect(rendered).to include("falls outside the prior month")
      end
    end

    context "when user has no unused data" do
      before do
        engagement_form.update!(has_job: true)
        create(:job_paycheck, 
          engagement_form: engagement_form,
          pay_date: prior_month + 15.days,
          gross_pay_amount: 600.0,
          hours_worked: 40.0
        )
      end

      it "renders successfully" do
        expect { render template: "engagement_forms/show", formats: [:pdf] }.not_to raise_error
      end

      it "does not include unused data alert" do
        render template: "engagement_forms/show", formats: [:pdf]
        expect(rendered).not_to include("Data Not Used for Verification")
      end
    end
  end
end
