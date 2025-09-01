# Improve PDF report styling
_Exported on 9/1/2025 at 16:46:45 PDT from Cursor (1.5.9)_

---

**User**

Let's improve the styling of the PDF version of the report. Let's start by formatting each section's answers into a table.

---

**Cursor**

I'll help you improve the styling of the PDF version by formatting the answers into tables. Let me first examine the current summary view to understand the structure.


Now let me check if there's a PDF-specific view or if we need to create one. Let me search for PDF-related files:


Great! I can see there are PDF-specific views. Let me check the current PDF view for the summary:


Let me check if there's a PDF view for the summary controller:


Let me check the routes to see if there's a PDF route for the summary:


Let me check the routes file to see the current routing structure:


I can see that the PDF download route points to `engagement_forms#show` with a PDF format. Let me check if there's a PDF view for the engagement form:


Perfect! I can see that there's already a PDF view for the engagement form, but it's not using the USWDS table styling consistently. The current PDF view has some sections using tables (like job income and volunteering) but others using paragraph formatting. Let me improve the styling by converting all sections to use consistent table formatting.

Let me update the PDF view to use tables for all sections:


```erb
<div class="header">
  <h1>Community Engagement Requirement Report</h1>
  <p>Form ID: <%= @engagement_form.id %></p>
  <p>Submitted: <%= @engagement_form.created_at.strftime("%B %d, %Y at %I:%M %p") %></p>
</div>

<% verifier = EngagementRequirementsVerifier.new(@engagement_form) %>
<% details = verifier.verification_details %>

<% if verifier.meets_requirements? %>
  <div class="usa-alert usa-alert--success" style="margin: 20px 0; padding: 15px; background-color: #d4edda; border: 1px solid #c3e6cb; border-radius: 4px;">
    <div class="usa-alert__body">
      <h3 class="usa-alert__heading" style="margin: 0 0 10px 0; color: #155724; font-size: 18px;">Requirements Met</h3>
      <div class="usa-alert__text" style="color: #155724;">
        <% if details[:enrolled_half_time_or_more] %>
          <p style="margin: 5px 0;"><strong>Qualification:</strong> Enrolled at least half-time in school</p>
        <% elsif details[:income_requirement_met] %>
          <p style="margin: 5px 0;"><strong>Qualification:</strong> Gross monthly income of $<%= number_with_precision(details[:total_income], precision: 2) %> (meets minimum of $580)</p>
        <% elsif details[:hours_requirement_met] %>
          <p style="margin: 5px 0;"><strong>Qualification:</strong> Total of <%= details[:total_hours] %> hours (meets minimum of 80 hours)</p>
          <p style="margin: 5px 0; font-size: 14px;">
            Breakdown: 
            <% breakdown_parts = [] %>
            <% breakdown_parts << "#{details[:work_hours]} work hours" if details[:work_hours] > 0 %>
            <% breakdown_parts << "#{details[:school_hours]} school hours" if details[:school_hours] > 0 %>
            <% breakdown_parts << "#{details[:work_program_hours]} work program hours" if details[:work_program_hours] > 0 %>
            <% breakdown_parts << "#{details[:volunteer_hours]} volunteer hours" if details[:volunteer_hours] > 0 %>
            <%= breakdown_parts.join(", ") %>
          </p>
        <% end %>
      </div>
    </div>
  </div>
<% else %>
  <div class="usa-alert usa-alert--warning" style="margin: 20px 0; padding: 15px; background-color: #fff3cd; border: 1px solid #ffeaa7; border-radius: 4px;">
    <div class="usa-alert__body">
      <h3 class="usa-alert__heading" style="margin: 0 0 10px 0; color: #856404; font-size: 18px;">Requirements Not Met</h3>
      <div class="usa-alert__text" style="color: #856404;">
        <p style="margin: 5px 0;">Based on the information provided, the user does not meet Community Engagement Requirements.</p>
        
        <p style="margin: 10px 0; font-weight: bold;">Explanation:</p>
        <ul style="margin: 10px 0; padding-left: 20px;">
          <% if @engagement_form.is_student? && @engagement_form.enrollment_status == "less_than_half_time" %>
            <li style="margin: 5px 0;">Enrolled less than half-time in school</li>
          <% elsif @engagement_form.is_student? && @engagement_form.enrollment_status == "half_time_or_more" %>
            <li style="margin: 5px 0;">Enrolled half-time or more (should qualify - please check data)</li>
          <% else %>
            <li style="margin: 5px 0;">Not enrolled in school</li>
          <% end %>
          
          <% if @engagement_form.has_job? %>
            <li style="margin: 5px 0;">Gross monthly income: $<%= number_with_precision(details[:total_income], precision: 2) %> (minimum required: $580)</li>
          <% else %>
            <li style="margin: 5px 0;">No employment income reported</li>
          <% end %>
          
          <li style="margin: 5px 0;">Total hours: <%= details[:total_hours] %> (minimum required: 80)</li>
          <% if details[:total_hours] > 0 %>
            <li style="margin: 5px 0; font-size: 14px; margin-left: 20px;">
              Breakdown: 
              <% breakdown_parts = [] %>
              <% breakdown_parts << "#{details[:work_hours]} work hours" if details[:work_hours] > 0 %>
              <% breakdown_parts << "#{details[:school_hours]} school hours" if details[:school_hours] > 0 %>
              <% breakdown_parts << "#{details[:work_program_hours]} work program hours" if details[:work_program_hours] > 0 %>
              <% breakdown_parts << "#{details[:volunteer_hours]} volunteer hours" if details[:volunteer_hours] > 0 %>
              <%= breakdown_parts.join(", ") %>
            </li>
          <% end %>
        </ul>
      </div>
    </div>
  </div>
<% end %>

<% if details[:unused_data].any? %>
  <div class="usa-alert usa-alert--info" style="margin: 20px 0; padding: 15px; background-color: #d1ecf1; border: 1px solid #bee5eb; border-radius: 4px;">
    <div class="usa-alert__body">
      <h3 class="usa-alert__heading" style="margin: 0 0 10px 0; color: #0c5460; font-size: 16px;">Data Not Used for Verification</h3>
      <div class="usa-alert__text" style="color: #0c5460; font-size: 14px;">
        <p style="margin: 5px 0;">The following data was not used for verification because it falls outside the prior month (<%= @engagement_form.prior_month_name %>):</p>
        
        <% if details[:unused_data][:job_paychecks] %>
          <div style="margin: 10px 0;">
            <strong>Job Paychecks:</strong>
            <ul style="margin: 5px 0; padding-left: 20px;">
              <li><%= details[:unused_data][:job_paychecks][:count] %> paycheck(s) from <%= details[:unused_data][:job_paychecks][:months].join(", ") %></li>
              <li>Total income: $<%= number_with_precision(details[:unused_data][:job_paychecks][:total_income], precision: 2) %></li>
              <li>Total hours: <%= details[:unused_data][:job_paychecks][:total_hours] %></li>
            </ul>
          </div>
        <% end %>
        
        <% if details[:unused_data][:volunteer_shifts] %>
          <div style="margin: 10px 0;">
            <strong>Volunteer Shifts:</strong>
            <ul style="margin: 5px 0; padding-left: 20px;">
              <li><%= details[:unused_data][:volunteer_shifts][:count] %> shift(s) from <%= details[:unused_data][:volunteer_shifts][:months].join(", ") %></li>
              <li>Total hours: <%= details[:unused_data][:volunteer_shifts][:total_hours] %></li>
            </ul>
          </div>
        <% end %>
      </div>
    </div>
  </div>
<% end %>

<div class="section">
  <h2>Basic Information</h2>
  
  <table style="width: 100%; border-collapse: collapse; margin-top: 10px;">
    <tbody>
      <tr>
        <td style="border: 1px solid #ccc; padding: 8px; font-weight: bold; background-color: #f0f0f0; width: 30%;">Full Name:</td>
        <td style="border: 1px solid #ccc; padding: 8px;"><%= @engagement_form.user_name %></td>
      </tr>
      <tr>
        <td style="border: 1px solid #ccc; padding: 8px; font-weight: bold; background-color: #f0f0f0;">Email Address:</td>
        <td style="border: 1px solid #ccc; padding: 8px;"><%= @engagement_form.email %></td>
      </tr>
    </tbody>
  </table>
</div>

<div class="section">
  <h2>Community Engagement Activities</h2>
  
  <table style="width: 100%; border-collapse: collapse; margin-top: 10px;">
    <tbody>
      <tr>
        <td style="border: 1px solid #ccc; padding: 8px; font-weight: bold; background-color: #f0f0f0; width: 30%;">Engagement Types:</td>
        <td style="border: 1px solid #ccc; padding: 8px;">
          <ul style="margin: 5px 0; padding-left: 20px;">
            <% if @engagement_form.has_job? %>
              <li style="margin: 3px 0;">Has a job</li>
            <% end %>
            <% if @engagement_form.is_student? %>
              <li style="margin: 3px 0;">Is a student</li>
            <% end %>
            <% if @engagement_form.enrolled_work_program? %>
              <li style="margin: 3px 0;">Enrolled in work program</li>
            <% end %>
            <% if @engagement_form.volunteers_nonprofit? %>
              <li style="margin: 3px 0;">Volunteers with nonprofit</li>
            <% end %>
          </ul>
        </td>
      </tr>
    </tbody>
  </table>
  
  <% if @engagement_form.has_job? %>
    <h3>Job Income Details</h3>
    <% if @engagement_form.job_paychecks.any? %>
      <table style="width: 100%; border-collapse: collapse; margin-top: 10px;">
        <thead>
          <tr style="background-color: #f0f0f0;">
            <th style="border: 1px solid #ccc; padding: 8px; text-align: left;">Pay Date</th>
            <th style="border: 1px solid #ccc; padding: 8px; text-align: left;">Gross Pay</th>
            <th style="border: 1px solid #ccc; padding: 8px; text-align: left;">Hours</th>
          </tr>
        </thead>
        <tbody>
          <% @engagement_form.job_paychecks.ordered_by_date.each do |paycheck| %>
            <tr>
              <td style="border: 1px solid #ccc; padding: 8px;"><%= paycheck.pay_date.strftime("%B %d, %Y") %></td>
              <td style="border: 1px solid #ccc; padding: 8px;">$<%= number_with_precision(paycheck.gross_pay_amount, precision: 2) %></td>
              <td style="border: 1px solid #ccc; padding: 8px;"><%= paycheck.hours_worked %></td>
            </tr>
          <% end %>
        </tbody>
      </table>
      
      <table style="width: 100%; border-collapse: collapse; margin-top: 10px;">
        <tbody>
          <tr>
            <td style="border: 1px solid #ccc; padding: 8px; font-weight: bold; background-color: #f0f0f0; width: 30%;">Total Hours:</td>
            <td style="border: 1px solid #ccc; padding: 8px;"><%= @engagement_form.job_paychecks.sum(&:hours_worked) %></td>
          </tr>
          <tr>
            <td style="border: 1px solid #ccc; padding: 8px; font-weight: bold; background-color: #f0f0f0;">Total Gross Pay:</td>
            <td style="border: 1px solid #ccc; padding: 8px;">$<%= number_with_precision(@engagement_form.job_paychecks.sum(&:gross_pay_amount), precision: 2) %></td>
          </tr>
        </tbody>
      </table>
    <% else %>
      <table style="width: 100%; border-collapse: collapse; margin-top: 10px;">
        <tbody>
          <tr>
            <td style="border: 1px solid #ccc; padding: 8px; font-weight: bold; background-color: #f0f0f0; width: 30%;">Status:</td>
            <td style="border: 1px solid #ccc; padding: 8px;">No paychecks have been added yet.</td>
          </tr>
        </tbody>
      </table>
    <% end %>
  <% end %>
  
  <% if @engagement_form.is_student? %>
    <h3>Student Details</h3>
    <table style="width: 100%; border-collapse: collapse; margin-top: 10px;">
      <tbody>
        <% if @engagement_form.school_name.present? %>
          <tr>
            <td style="border: 1px solid #ccc; padding: 8px; font-weight: bold; background-color: #f0f0f0; width: 30%;">School:</td>
            <td style="border: 1px solid #ccc; padding: 8px;"><%= @engagement_form.school_name %></td>
          </tr>
        <% end %>
        <% if @engagement_form.enrollment_status == "half_time_or_more" %>
          <tr>
            <td style="border: 1px solid #ccc; padding: 8px; font-weight: bold; background-color: #f0f0f0;">Enrollment Status:</td>
            <td style="border: 1px solid #ccc; padding: 8px;">Enrolled at least half-time</td>
          </tr>
        <% elsif @engagement_form.enrollment_status == "less_than_half_time" %>
          <tr>
            <td style="border: 1px solid #ccc; padding: 8px; font-weight: bold; background-color: #f0f0f0;">Enrollment Status:</td>
            <td style="border: 1px solid #ccc; padding: 8px;">Enrolled less than half-time</td>
          </tr>
          <% if @engagement_form.school_hours.present? %>
            <tr>
              <td style="border: 1px solid #ccc; padding: 8px; font-weight: bold; background-color: #f0f0f0;">School Hours per Week:</td>
              <td style="border: 1px solid #ccc; padding: 8px;"><%= @engagement_form.school_hours %> hours</td>
            </tr>
          <% end %>
        <% end %>
      </tbody>
    </table>
  <% end %>
  
  <% if @engagement_form.enrolled_work_program? %>
    <h3>Work Program Details</h3>
    <table style="width: 100%; border-collapse: collapse; margin-top: 10px;">
      <tbody>
        <% if @engagement_form.work_program_name.present? %>
          <tr>
            <td style="border: 1px solid #ccc; padding: 8px; font-weight: bold; background-color: #f0f0f0; width: 30%;">Work Program Name:</td>
            <td style="border: 1px solid #ccc; padding: 8px;"><%= @engagement_form.work_program_name %></td>
          </tr>
        <% end %>
        <% if @engagement_form.hours_attended.present? %>
          <tr>
            <td style="border: 1px solid #ccc; padding: 8px; font-weight: bold; background-color: #f0f0f0;">Hours Attended:</td>
            <td style="border: 1px solid #ccc; padding: 8px;"><%= @engagement_form.hours_attended %> hours</td>
          </tr>
        <% end %>
      </tbody>
    </table>
  <% end %>
  
  <% if @engagement_form.volunteers_nonprofit? %>
    <h3>Volunteering Details</h3>
    <% if @engagement_form.volunteer_shifts.any? %>
      <table style="width: 100%; border-collapse: collapse; margin-top: 10px;">
        <thead>
          <tr style="background-color: #f0f0f0;">
            <th style="border: 1px solid #ccc; padding: 8px; text-align: left;">Organization</th>
            <th style="border: 1px solid #ccc; padding: 8px; text-align: left;">Date</th>
            <th style="border: 1px solid #ccc; padding: 8px; text-align: left;">Hours</th>
          </tr>
        </thead>
        <tbody>
          <% @engagement_form.volunteer_shifts.ordered_by_date.each do |shift| %>
            <tr>
              <td style="border: 1px solid #ccc; padding: 8px;"><%= shift.organization_name %></td>
              <td style="border: 1px solid #ccc; padding: 8px;"><%= shift.shift_date.strftime("%B %d, %Y") %></td>
              <td style="border: 1px solid #ccc; padding: 8px;"><%= shift.hours %></td>
            </tr>
          <% end %>
        </tbody>
      </table>
      
      <table style="width: 100%; border-collapse: collapse; margin-top: 10px;">
        <tbody>
          <tr>
            <td style="border: 1px solid #ccc; padding: 8px; font-weight: bold; background-color: #f0f0f0; width: 30%;">Total Volunteer Hours:</td>
            <td style="border: 1px solid #ccc; padding: 8px;"><%= @engagement_form.volunteer_shifts.sum(&:hours) %></td>
          </tr>
        </tbody>
      </table>
    <% else %>
      <table style="width: 100%; border-collapse: collapse; margin-top: 10px;">
        <tbody>
          <tr>
            <td style="border: 1px solid #ccc; padding: 8px; font-weight: bold; background-color: #f0f0f0; width: 30%;">Status:</td>
            <td style="border: 1px solid #ccc; padding: 8px;">No volunteer shifts have been added yet.</td>
          </tr>
        </tbody>
      </table>
    <% end %>
  <% end %>
</div>
```

Perfect! I've successfully updated the PDF view to use consistent table formatting for all sections. The changes include:

1. **Community Engagement Activities section** - Now uses a table format instead of div/span elements
2. **Job Income Details** - Consolidated the conditional logic and added a summary table for totals
3. **Student Details** - Converted from paragraph format to table format
4. **Work Program Details** - Converted from paragraph format to table format  
5. **Volunteering Details** - Added a summary table for total hours and improved the conditional structure

All sections now use consistent table styling with:
- 30% width for labels (with gray background)
- Consistent borders and padding
- Proper spacing between sections
- Clean, professional appearance that will print well in PDF format

The PDF will now have a much more organized and professional look with all information presented in easy-to-read table format.

---

**User**

Put the tables containing the Totals before the tables containing the broken out data.

---

**Cursor**

I'll reorder the tables so that the summary/totals tables appear before the detailed data tables. This will make the PDF more scannable by showing the key information first.


```erb
  <% if @engagement_form.has_job? %>
    <h3>Job Income Details</h3>
    <% if @engagement_form.job_paychecks.any? %>
      <table style="width: 100%; border-collapse: collapse; margin-top: 10px;">
        <thead>
          <tr style="background-color: #f0f0f0;">
            <th style="border: 1px solid #ccc; padding: 8px; text-align: left;">Pay Date</th>
            <th style="border: 1px solid #ccc; padding: 8px; text-align: left;">Gross Pay</th>
            <th style="border: 1px solid #ccc; padding: 8px; text-align: left;">Hours</th>
          </tr>
        </thead>
        <tbody>
          <% @engagement_form.job_paychecks.ordered_by_date.each do |paycheck| %>
            <tr>
              <td style="border: 1px solid #ccc; padding: 8px;"><%= paycheck.pay_date.strftime("%B %d, %Y") %></td>
              <td style="border: 1px solid #ccc; padding: 8px;">$<%= number_with_precision(paycheck.gross_pay_amount, precision: 2) %></td>
              <td style="border: 1px solid #ccc; padding: 8px;"><%= paycheck.hours_worked %></td>
            </tr>
          <% end %>
        </tbody>
      </table>
      
      <table style="width: 100%; border-collapse: collapse; margin-top: 10px;">
        <tbody>
          <tr>
            <td style="border: 1px solid #ccc; padding: 8px; font-weight: bold; background-color: #f0f0f0; width: 30%;">Total Hours:</td>
            <td style="border: 1px solid #ccc; padding: 8px;"><%= @engagement_form.job_paychecks.sum(&:hours_worked) %></td>
          </tr>
          <tr>
            <td style="border: 1px solid #ccc; padding: 8px; font-weight: bold; background-color: #f0f0f0;">Total Gross Pay:</td>
            <td style="border: 1px solid #ccc; padding: 8px;">$<%= number_with_precision(@engagement_form.job_paychecks.sum(&:gross_pay_amount), precision: 2) %></td>
          </tr>
        </tbody>
      </table>
    <% else %>
      <table style="width: 100%; border-collapse: collapse; margin-top: 10px;">
        <tbody>
          <tr>
            <td style="border: 1px solid #ccc; padding: 8px; font-weight: bold; background-color: #f0f0f0; width: 30%;">Status:</td>
            <td style="border: 1px solid #ccc; padding: 8px;">No paychecks have been added yet.</td>
          </tr>
        </tbody>
      </table>
    <% end %>
  <% end %>

->

  <% if @engagement_form.has_job? %>
    <h3>Job Income Details</h3>
    <% if @engagement_form.job_paychecks.any? %>
      <table style="width: 100%; border-collapse: collapse; margin-top: 10px;">
        <tbody>
          <tr>
            <td style="border: 1px solid #ccc; padding: 8px; font-weight: bold; background-color: #f0f0f0; width: 30%;">Total Hours:</td>
            <td style="border: 1px solid #ccc; padding: 8px;"><%= @engagement_form.job_paychecks.sum(&:hours_worked) %></td>
          </tr>
          <tr>
            <td style="border: 1px solid #ccc; padding: 8px; font-weight: bold; background-color: #f0f0f0;">Total Gross Pay:</td>
            <td style="border: 1px solid #ccc; padding: 8px;">$<%= number_with_precision(@engagement_form.job_paychecks.sum(&:gross_pay_amount), precision: 2) %></td>
          </tr>
        </tbody>
      </table>
      
      <table style="width: 100%; border-collapse: collapse; margin-top: 10px;">
        <thead>
          <tr style="background-color: #f0f0f0;">
            <th style="border: 1px solid #ccc; padding: 8px; text-align: left;">Pay Date</th>
            <th style="border: 1px solid #ccc; padding: 8px; text-align: left;">Gross Pay</th>
            <th style="border: 1px solid #ccc; padding: 8px; text-align: left;">Hours</th>
          </tr>
        </thead>
        <tbody>
          <% @engagement_form.job_paychecks.ordered_by_date.each do |paycheck| %>
            <tr>
              <td style="border: 1px solid #ccc; padding: 8px;"><%= paycheck.pay_date.strftime("%B %d, %Y") %></td>
              <td style="border: 1px solid #ccc; padding: 8px;">$<%= number_with_precision(paycheck.gross_pay_amount, precision: 2) %></td>
              <td style="border: 1px solid #ccc; padding: 8px;"><%= paycheck.hours_worked %></td>
            </tr>
          <% end %>
        </tbody>
      </table>
    <% else %>
      <table style="width: 100%; border-collapse: collapse; margin-top: 10px;">
        <tbody>
          <tr>
            <td style="border: 1px solid #ccc; padding: 8px; font-weight: bold; background-color: #f0f0f0; width: 30%;">Status:</td>
            <td style="border: 1px solid #ccc; padding: 8px;">No paychecks have been added yet.</td>
          </tr>
        </tbody>
      </table>
    <% end %>
  <% end %>
```

Now let me also reorder the volunteering section to show totals before the detailed data:


```erb
  <% if @engagement_form.volunteers_nonprofit? %>
    <h3>Volunteering Details</h3>
    <% if @engagement_form.volunteer_shifts.any? %>
      <table style="width: 100%; border-collapse: collapse; margin-top: 10px;">
        <thead>
          <tr style="background-color: #f0f0f0;">
            <th style="border: 1px solid #ccc; padding: 8px; text-align: left;">Organization</th>
            <th style="border: 1px solid #ccc; padding: 8px; text-align: left;">Date</th>
            <th style="border: 1px solid #ccc; padding: 8px; text-align: left;">Hours</th>
          </tr>
        </thead>
        <tbody>
          <% @engagement_form.volunteer_shifts.ordered_by_date.each do |shift| %>
            <tr>
              <td style="border: 1px solid #ccc; padding: 8px;"><%= shift.organization_name %></td>
              <td style="border: 1px solid #ccc; padding: 8px;"><%= shift.shift_date.strftime("%B %d, %Y") %></td>
              <td style="border: 1px solid #ccc; padding: 8px;"><%= shift.hours %></td>
            </tr>
          <% end %>
        </tbody>
      </table>
      
      <table style="width: 100%; border-collapse: collapse; margin-top: 10px;">
        <tbody>
          <tr>
            <td style="border: 1px solid #ccc; padding: 8px; font-weight: bold; background-color: #f0f0f0; width: 30%;">Total Volunteer Hours:</td>
            <td style="border: 1px solid #ccc; padding: 8px;"><%= @engagement_form.volunteer_shifts.sum(&:hours) %></td>
          </tr>
        </tbody>
      </table>
    <% else %>
      <table style="width: 100%; border-collapse: collapse; margin-top: 10px;">
        <tbody>
          <tr>
            <td style="border: 1px solid #ccc; padding: 8px; font-weight: bold; background-color: #f0f0f0; width: 30%;">Status:</td>
            <td style="border: 1px solid #ccc; padding: 8px;">No volunteer shifts have been added yet.</td>
          </tr>
        </tbody>
      </table>
    <% end %>
  <% end %>

->

  <% if @engagement_form.volunteers_nonprofit? %>
    <h3>Volunteering Details</h3>
    <% if @engagement_form.volunteer_shifts.any? %>
      <table style="width: 100%; border-collapse: collapse; margin-top: 10px;">
        <tbody>
          <tr>
            <td style="border: 1px solid #ccc; padding: 8px; font-weight: bold; background-color: #f0f0f0; width: 30%;">Total Volunteer Hours:</td>
            <td style="border: 1px solid #ccc; padding: 8px;"><%= @engagement_form.volunteer_shifts.sum(&:hours) %></td>
          </tr>
        </tbody>
      </table>
      
      <table style="width: 100%; border-collapse: collapse; margin-top: 10px;">
        <thead>
          <tr style="background-color: #f0f0f0;">
            <th style="border: 1px solid #ccc; padding: 8px; text-align: left;">Organization</th>
            <th style="border: 1px solid #ccc; padding: 8px; text-align: left;">Date</th>
            <th style="border: 1px solid #ccc; padding: 8px; text-align: left;">Hours</th>
          </tr>
        </thead>
        <tbody>
          <% @engagement_form.volunteer_shifts.ordered_by_date.each do |shift| %>
            <tr>
              <td style="border: 1px solid #ccc; padding: 8px;"><%= shift.organization_name %></td>
              <td style="border: 1px solid #ccc; padding: 8px;"><%= shift.shift_date.strftime("%B %d, %Y") %></td>
              <td style="border: 1px solid #ccc; padding: 8px;"><%= shift.hours %></td>
            </tr>
          <% end %>
        </tbody>
      </table>
    <% else %>
      <table style="width: 100%; border-collapse: collapse; margin-top: 10px;">
        <tbody>
          <tr>
            <td style="border: 1px solid #ccc; padding: 8px; font-weight: bold; background-color: #f0f0f0; width: 30%;">Status:</td>
            <td style="border: 1px solid #ccc; padding: 8px;">No volunteer shifts have been added yet.</td>
          </tr>
        </tbody>
      </table>
    <% end %>
  <% end %>
```

Perfect! I've reordered the tables so that the summary/totals information appears before the detailed breakdown data. Now the PDF will show:

1. **Job Income Details** - Total hours and gross pay first, then the detailed paycheck table
2. **Volunteering Details** - Total volunteer hours first, then the detailed volunteer shifts table

This makes the PDF much more scannable and professional, as users can quickly see the key totals before diving into the detailed data. The summary information is now prominently displayed at the top of each section.

