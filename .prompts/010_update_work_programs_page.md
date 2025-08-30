# Update work programs page fields
_Exported on 8/30/2025 at 14:41:54 PDT from Cursor (1.5.7)_

---

**User**

Next we will update the "work programs" page.

1. Remove the "work_programs_details" field from the view, the database, the tests, and the Agents.md documentation.

2. Add new fields to the "work programs" page:
* Work Program Name (string)
* Hours Attended (number)

Update the "review" and PDF to incorporate these fields, and the Agents.md documentation as well.

---

**Cursor**

I'll help you update the work programs page by removing the `work_program_details` field and adding the new fields. Let me start by examining the current structure and then make the necessary changes.


Now let me check the model and database structure:


Let me check the EngagementForm model to see the current database structure:


Let me check the database migrations to understand the current schema:


Now let me check the review and PDF generation files:


Now let me check the tests to see what needs to be updated:


Now let me check the Agents.md file to see what needs to be updated:


Now I'll start implementing the changes. First, let me create a migration to remove the `work_program_details` field and add the new fields:


```ruby
class UpdateWorkProgramFields < ActiveRecord::Migration[8.0]
  def change
    remove_column :engagement_forms, :work_program_details, :text
    add_column :engagement_forms, :work_program_name, :string
    add_column :engagement_forms, :hours_attended, :decimal, precision: 8, scale: 2
  end
end
```

Now let me run the migration:


Now let me update the work programs view to use the new fields:


```ruby
<div class="grid-row">
  <div class="grid-col-12 usa-prose">
    <h1>Work Program Details</h1>
    
    <p class="usa-intro">
      Please provide details about your work program to help verify that you meet the Community Engagement Requirements.
    </p>
    
    <%= form_with model: @engagement_form, url: engagement_form_work_programs_path(@engagement_form), method: :post, local: true, class: "usa-form" do |form| %>
      
      <fieldset class="usa-fieldset">
        <legend class="usa-legend">Work Program Details</legend>
        
        <div class="usa-form-group">
          <%= form.label :work_program_name, "Work Program Name:", class: "usa-label" %>
          <div class="usa-hint" id="work-program-name-hint">
            Enter the name of the work program you are enrolled in.
          </div>
          <%= form.text_field :work_program_name, class: "usa-input", "aria-describedby": "work-program-name-hint" %>
        </div>
        
        <div class="usa-form-group">
          <%= form.label :hours_attended, "Hours Attended:", class: "usa-label" %>
          <div class="usa-hint" id="hours-attended-hint">
            Enter the total number of hours you have attended in this work program.
          </div>
          <%= form.number_field :hours_attended, class: "usa-input", step: "0.01", min: "0", "aria-describedby": "hours-attended-hint" %>
        </div>
      </fieldset>
      
      <div class="usa-form-group">
        <%= form.submit "Continue", class: "usa-button" %>
        <%= link_to "Back", new_engagement_form_question_path(@engagement_form), class: "usa-button usa-button--outline" %>
      </div>
    <% end %>
  </div>
</div>
```

Now let me update the work programs controller to handle the new fields:


```ruby
class WorkProgramsController < ApplicationController
  def new
    @engagement_form = EngagementForm.find(params[:engagement_form_id])
  end

  def create
    @engagement_form = EngagementForm.find(params[:engagement_form_id])
    
    # Handle both nested and direct parameters
    work_program_params = params[:engagement_form]&.slice(:work_program_name, :hours_attended) || 
                         params.slice(:work_program_name, :hours_attended)
    @engagement_form.update(work_program_params)
    
    # Use the new next_path method
    redirect_to next_path(@engagement_form)
  end
  
  # Class method to determine if this controller should be skipped
  def self.skip?(engagement_form)
    !engagement_form.enrolled_work_program?
  end
end
```

Now let me update the review page to display the new fields:


```ruby
    <% if @engagement_form.enrolled_work_program? %>
      <div class="usa-summary-box">
        <div class="usa-summary-box__body">
          <h3 class="usa-summary-box__heading">
            Work Program Details
            <%= link_to "Edit", new_engagement_form_work_program_path(@engagement_form), class: "usa-button usa-button--small usa-button--outline", style: "float: right;" %>
          </h3>
          <div class="usa-summary-box__text">
            <p><%= @engagement_form.work_program_details %></p>
          </div>
        </div>
      </div>
    <% end %>

->

    <% if @engagement_form.enrolled_work_program? %>
      <div class="usa-summary-box">
        <div class="usa-summary-box__body">
          <h3 class="usa-summary-box__heading">
            Work Program Details
            <%= link_to "Edit", new_engagement_form_work_program_path(@engagement_form), class: "usa-button usa-button--small usa-button--outline", style: "float: right;" %>
          </h3>
          <div class="usa-summary-box__text">
            <% if @engagement_form.work_program_name.present? %>
              <p><strong>Work Program Name:</strong> <%= @engagement_form.work_program_name %></p>
            <% end %>
            <% if @engagement_form.hours_attended.present? %>
              <p><strong>Hours Attended:</strong> <%= @engagement_form.hours_attended %> hours</p>
            <% end %>
          </div>
        </div>
      </div>
    <% end %>
```

Now let me update the PDF template to include the new fields:


```ruby
  <% if @engagement_form.work_program_details.present? %>
    <div class="field">
      <span class="field-label">Work Program Details:</span>
      <div class="field-value"><%= @engagement_form.work_program_details %></div>
    </div>
  <% end %>

->

  <% if @engagement_form.enrolled_work_program? %>
    <div class="field">
      <span class="field-label">Work Program Details:</span>
      <div class="field-value">
        <% if @engagement_form.work_program_name.present? %>
          <p><strong>Work Program Name:</strong> <%= @engagement_form.work_program_name %></p>
        <% end %>
        <% if @engagement_form.hours_attended.present? %>
          <p><strong>Hours Attended:</strong> <%= @engagement_form.hours_attended %> hours</p>
        <% end %>
      </div>
    </div>
  <% end %>
```

Now let me update the tests to use the new fields:


```ruby
require 'rails_helper'

RSpec.describe "WorkPrograms", type: :request do
  let(:engagement_form) { EngagementForm.create!(user_name: "Test User", email: "test@example.com") }

  describe "GET /new" do
    it "returns http success" do
      get "/engagement_forms/#{engagement_form.id}/work_programs/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /create" do
    it "returns http success" do
      post "/engagement_forms/#{engagement_form.id}/work_programs", params: { 
        work_program_name: "Test Work Program", 
        hours_attended: 40.5 
      }
      expect(response).to have_http_status(:redirect)
    end
  end

end
```

Now let me update the Agents.md file to reflect the new schema:


```markdown
# Detail fields
school_name: string
enrollment_status: string
school_hours: decimal
work_program_details: text

->

# Detail fields
school_name: string
enrollment_status: string
school_hours: decimal
work_program_name: string
hours_attended: decimal
```

Now let me run the tests to make sure everything is working:


I need to fix the controller to properly handle the parameters. The issue is with the parameter handling. Let me update the controller:


```ruby
class WorkProgramsController < ApplicationController
  def new
    @engagement_form = EngagementForm.find(params[:engagement_form_id])
  end

  def create
    @engagement_form = EngagementForm.find(params[:engagement_form_id])
    
    # Handle both nested and direct parameters
    work_program_params = params[:engagement_form]&.permit(:work_program_name, :hours_attended) || 
                         params.permit(:work_program_name, :hours_attended)
    @engagement_form.update(work_program_params)
    
    # Use the new next_path method
    redirect_to next_path(@engagement_form)
  end
  
  # Class method to determine if this controller should be skipped
  def self.skip?(engagement_form)
    !engagement_form.enrolled_work_program?
  end
end
```

Now let me run the tests again:


Great! Now let me run all the tests to make sure I didn't break anything else:


Perfect! All tests are passing. Now let me start the Rails server to test the new functionality:


Perfect! I've successfully updated the work programs page with the following changes:

## ✅ **Work Programs Page Updated**

### **Changes Made:**

1. **Database Migration:**
   - Removed `work_program_details` (text) field
   - Added `work_program_name` (string) field  
   - Added `hours_attended` (decimal) field with precision 8, scale 2

2. **Form Updates:**
   - Updated `app/views/work_programs/new.html.erb` to use the new fields
   - Replaced text area with separate input fields for program name and hours
   - Added proper USWDS styling and accessibility attributes

3. **Controller Updates:**
   - Updated `WorkProgramsController` to handle the new parameter structure
   - Fixed parameter permitting for security

4. **Review & PDF Updates:**
   - Updated `app/views/summary/review.html.erb` to display new fields
   - Updated `app/views/engagement_forms/show.pdf.erb` to include new fields in PDF output

5. **Test Updates:**
   - Updated `spec/requests/work_programs_spec.rb` to test new fields
   - All tests passing

6. **Documentation Updates:**
   - Updated `Agents.md` to reflect new database schema

### **New Fields:**
- **Work Program Name:** Text input for the program name
- **Hours Attended:** Number input with decimal support for tracking total hours

The application is now running on `http://localhost:3000` and ready for testing. The work programs page now collects structured data instead of free-form text, making it easier to process and display the information consistently.

