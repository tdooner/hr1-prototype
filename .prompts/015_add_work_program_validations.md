# Add validations for work programs form
_Exported on 8/30/2025 at 16:27:22 PDT from Cursor (1.5.7)_

---

**User**

Add validations to the "work programs" page to require valid values for the name and hours fields, when that page's form is submitted.

---

**Cursor**

I'll help you add validations to the "work programs" page. First, let me explore the codebase to understand the current structure and find the relevant files.


Now let me search for the EngagementForm model to understand the current validation structure:


Now let me read the current work programs form to understand its structure:


Now let me check the work programs controller to understand how it handles the form submission:


Now let me check the EngagementForm model to see if there are any existing validations for work program fields:


Perfect! Now I understand the structure. I need to add validations for the work program fields using validation contexts, similar to how the student validations are implemented. Let me add the work program validations to the model and update the controller to handle validation errors.


```ruby
class EngagementForm < ApplicationRecord
  validates :user_name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :application_date, presence: true
  
  # Student-specific validations
  validates :school_name, presence: true, on: :students_page
  validates :enrollment_status, presence: true, on: :students_page
  validate :school_hours_required_when_less_than_half_time, on: :students_page
  
  # Work program-specific validations
  validates :work_program_name, presence: true, on: :work_programs_page
  validates :hours_attended, presence: true, numericality: { greater_than: 0 }, on: :work_programs_page
  
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
```

Now I need to update the work programs controller to use the validation context and handle validation errors:


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
    
    # Update the attributes
    @engagement_form.assign_attributes(work_program_params)
    
    # Validate with the work_programs_page context
    if @engagement_form.valid?(:work_programs_page)
      @engagement_form.save!
      # Use the new next_path method
      redirect_to next_path(@engagement_form)
    else
      # Re-render the form with validation errors
      render :new, status: :unprocessable_entity
    end
  end
  
  # Class method to determine if this controller should be skipped
  def self.skip?(engagement_form)
    !engagement_form.enrolled_work_program?
  end
end
```

Now I need to update the work programs form to display validation errors. Let me check if there's a helper method for displaying errors with USWDS styling:


Now I need to update the work programs form to use the new UswdsFormBuilder API:


```ruby
<div class="grid-row">
  <div class="grid-col-12 usa-prose">
    <h1>Work Program Details</h1>
    
    <p class="usa-intro">
      Please provide details about your work program participation in <%= @engagement_form.prior_month_name %> to help verify that you meet the Community Engagement Requirements.
    </p>
    
    <%= form_with model: @engagement_form, url: engagement_form_work_programs_path(@engagement_form), method: :post, local: true, class: "usa-form", builder: UswdsFormBuilder do |form| %>
      
      <% if @engagement_form.errors.any? %>
        <div class="usa-alert usa-alert--error" role="alert">
          <div class="usa-alert__body">
            <h4 class="usa-alert__heading">Please correct the following errors:</h4>
            <ul class="usa-alert__text">
              <% @engagement_form.errors.full_messages.each do |message| %>
                <li><%= message %></li>
              <% end %>
            </ul>
          </div>
        </div>
      <% end %>
      
      <fieldset class="usa-fieldset">
        <legend class="usa-legend--large">Work Program Details</legend>
        
        <%= form.text_field :work_program_name, "Work Program Name", "Enter the name of the work program you are enrolled in." %>
        
        <%= form.number_field :hours_attended, "Hours Attended", "Enter the total number of hours you have attended in this work program.", step: "0.01", min: "0" %>
      </fieldset>
      
      <div class="usa-form-group">
        <%= form.submit "Continue", class: "usa-button" %>
        <%= link_to "Back", new_engagement_form_question_path(@engagement_form), class: "usa-button usa-button--outline" %>
      </div>
    <% end %>
  </div>
</div>
```

Perfect! I've successfully added validations to the "work programs" page. Here's what I implemented:

## ✅ **Work Program Validations Added**

### **Model Validations:**
- **`work_program_name`**: Required field when on the work programs page
- **`hours_attended`**: Required field with numericality validation (must be greater than 0) when on the work programs page
- **Used validation contexts** (`on: :work_programs_page`) to ensure these validations only apply when the work programs form is submitted

### **Controller Updates:**
- **Updated `WorkProgramsController#create`** to use validation contexts with `@engagement_form.valid?(:work_programs_page)`
- **Added proper error handling** that re-renders the form with validation errors when validation fails
- **Used `assign_attributes` and `save!`** pattern for better control over the validation process

### **Form Updates:**
- **Updated the work programs form** to use the new `UswdsFormBuilder` for consistent styling
- **Added error display** that shows validation errors at the top of the form
- **Integrated with USWDS styling** for proper error message display

### **How it works:**
1. When the work programs form is submitted, the controller validates with the `:work_programs_page` context
2. If validation fails, the form re-renders with error messages displayed
3. The `UswdsFormBuilder` automatically adds error styling to fields with validation errors
4. Users can see exactly which fields need to be corrected and resubmit the form

The validations ensure that users must provide both a work program name and a valid number of hours attended before they can proceed to the next step in the form flow.

---

**User**

Move the errors alert outside of the <form> so it goes full width

---

**Cursor**

I'll move the error alert outside of the form so it spans the full width of the container. Let me update the work programs form:


```ruby
<div class="grid-row">
  <div class="grid-col-12 usa-prose">
    <h1>Work Program Details</h1>
    
    <p class="usa-intro">
      Please provide details about your work program participation in <%= @engagement_form.prior_month_name %> to help verify that you meet the Community Engagement Requirements.
    </p>
    
    <% if @engagement_form.errors.any? %>
      <div class="usa-alert usa-alert--error" role="alert">
        <div class="usa-alert__body">
          <h4 class="usa-alert__heading">Please correct the following errors:</h4>
          <ul class="usa-alert__text">
            <% @engagement_form.errors.full_messages.each do |message| %>
              <li><%= message %></li>
            <% end %>
          </ul>
        </div>
      </div>
    <% end %>
    
    <%= form_with model: @engagement_form, url: engagement_form_work_programs_path(@engagement_form), method: :post, local: true, class: "usa-form", builder: UswdsFormBuilder do |form| %>
      
      <fieldset class="usa-fieldset">
        <legend class="usa-legend--large">Work Program Details</legend>
        
        <%= form.text_field :work_program_name, "Work Program Name", "Enter the name of the work program you are enrolled in." %>
        
        <%= form.number_field :hours_attended, "Hours Attended", "Enter the total number of hours you have attended in this work program.", step: "0.01", min: "0" %>
      </fieldset>
      
      <div class="usa-form-group">
        <%= form.submit "Continue", class: "usa-button" %>
        <%= link_to "Back", new_engagement_form_question_path(@engagement_form), class: "usa-button usa-button--outline" %>
      </div>
    <% end %>
  </div>
</div>
```

Perfect! I've moved the error alert outside of the form element. Now the error messages will span the full width of the grid column instead of being constrained by the form's width. This makes the error messages more prominent and easier to read, following the same pattern used in other forms throughout the application.

The error alert now appears between the intro paragraph and the form, giving it proper visual separation and allowing it to use the full available width of the container.

