# Update application for prior month data
_Exported on 8/30/2025 at 14:56:56 PDT from Cursor (1.5.7)_

---

**User**

We need to update our application so that it's asking for all of this information in the context of a certain month. This month will be determined by the "application date" - the information must be provided for the month immediately prior to the month of the application date.

Add a new field to the Engagement Form basic information page to ask for the "application date".

Update all other pages to ask the user to input data for the month prior to the application date. For example, if the user inputs August 14, 2025 as their application date, then the other pages should ask for information like this: "Please add all the paychecks you received in July of 2025." (that's the example for the paychecks page)

---

**Cursor**

I'll help you update the application to include an application date field and modify all pages to ask for information from the month prior to that date. Let me start by examining the current structure of the engagement forms controller and related files.


Now let me check the EngagementForm model to understand its current structure:


Let me check the database migration to see the current schema:


Now let me check the views to understand the current form structure:


Now let me check what other pages exist in the application to understand what needs to be updated:


Let me check the questions controller and views since that seems to be where the main form flow goes:


Let me check the questions view to see what it asks:


Now let me check the job paychecks and volunteer shifts views to see what they currently ask for:


Let me also check the index pages to see how they currently display the information:


Let me check the jobs and volunteers controllers to see how they handle the data:


Now I have a good understanding of the current structure. Let me start implementing the changes:

1. First, I'll create a migration to add the application_date field to the engagement_forms table
2. Update the model to include the new field
3. Update the controller to permit the new parameter
4. Update the form to include the application date field
5. Update all the other pages to reference the month prior to the application date

Let's start:


Now let's update the EngagementForm model to include validation for the application_date:


```ruby
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
```

Now let's update the controller to permit the application_date parameter:


```ruby
  private

  def engagement_form_params
    params.require(:engagement_form).permit(:user_name, :email, :application_date)
  end
```

Now let's update the form to include the application date field:


```ruby
    <div class="usa-form-group">
      <%= form.label :email, "Email Address", class: "usa-label" %>
      <%= form.email_field :email, class: "usa-input", required: true %>
    </div>
    
    <div class="usa-form-group">
      <%= form.label :application_date, "Application Date", class: "usa-label" %>
      <div class="usa-hint" id="application-date-hint">
        Select the date you are submitting this application. Information will be collected for the month prior to this date.
      </div>
      <%= form.date_field :application_date, class: "usa-input", required: true, "aria-describedby": "application-date-hint" %>
    </div>
```

Now let's update the jobs page to reference the prior month:


```ruby
    <h1>Employment Details</h1>
    
    <p class="usa-intro">
      Please add all the paychecks you received in <%= @engagement_form.prior_month_name %> to help verify that you meet the Community Engagement Requirements.
    </p>
```

Now let's update the volunteers page to reference the prior month:


```ruby
    <h1>Volunteer Hours</h1>
    
    <p class="usa-intro">
      Please add all the volunteer shifts you completed in <%= @engagement_form.prior_month_name %> to help verify that you meet the Community Engagement Requirements.
    </p>
```

Now let's update the job paychecks form to reference the prior month:


```ruby
    <h1>Add Paycheck</h1>
    
    <p class="usa-intro">
      Please provide details about your paycheck from <%= @engagement_form.prior_month_name %>.
    </p>
```

Now let's update the volunteer shifts form to reference the prior month:


```ruby
    <h1>Add Volunteer Hours</h1>
    
    <p class="usa-intro">
      Please provide details about your volunteer shift from <%= @engagement_form.prior_month_name %>.
    </p>
```

Let me also check if there are any other views that might need updating. Let me look for any other pages that might reference time periods:


Let me check if there are any other controllers or views that might need updating. Let me look for any other pages that might be part of the form flow:


Let me check the work_programs and students views to see if they need updating:


Now let me update the work_programs and students pages to reference the prior month:


```ruby
    <h1>Work Program Details</h1>
    
    <p class="usa-intro">
      Please provide details about your work program participation in <%= @engagement_form.prior_month_name %> to help verify that you meet the Community Engagement Requirements.
    </p>
```

```ruby
    <h1>Student Details</h1>
    
    <p class="usa-intro">
      Please provide details about your education status in <%= @engagement_form.prior_month_name %> to help verify that you meet the Community Engagement Requirements.
    </p>
```

Now let me run the tests to make sure everything is working correctly:


I see that the tests are failing because they're trying to create EngagementForm records without the new required application_date field. I need to update the test files to include the application_date. Let me check one of the test files to see how they're structured:


I need to update all the test files to include the application_date. Let me start with the engagement_forms_spec.rb:


```ruby
require 'rails_helper'

RSpec.describe "EngagementForms", type: :request do
  let(:engagement_form) { EngagementForm.create!(user_name: "Test User", email: "test@example.com", application_date: Date.current) }

  describe "GET /new" do
    it "returns http success" do
      get "/engagement_forms/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /create" do
    it "creates a new engagement form and redirects to questions" do
      post "/engagement_forms", params: { engagement_form: { user_name: "John Doe", email: "john@example.com", application_date: Date.current } }
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(new_engagement_form_question_path(EngagementForm.last))
    end
  end

  describe "GET /edit" do
    it "returns http success" do
      get "/engagement_forms/#{engagement_form.id}/edit"
      expect(response).to have_http_status(:success)
    end

    it "displays the form with existing data" do
      get "/engagement_forms/#{engagement_form.id}/edit"
      expect(response.body).to include("Edit Basic Information")
      expect(response.body).to include(engagement_form.user_name)
      expect(response.body).to include(engagement_form.email)

    end
  end

  describe "PATCH /update" do
    it "updates the engagement form and redirects to review" do
      patch "/engagement_forms/#{engagement_form.id}", params: { engagement_form: { user_name: "Updated Name", email: "updated@example.com", application_date: Date.current } }
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(review_summary_path(engagement_form))
      
      engagement_form.reload
      expect(engagement_form.user_name).to eq("Updated Name")
      expect(engagement_form.email).to eq("updated@example.com")
      
    end

    it "renders edit view with errors if validation fails" do
              patch "/engagement_forms/#{engagement_form.id}", params: { engagement_form: { user_name: "", email: "invalid-email", application_date: nil } }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("Edit Basic Information")
    end
  end
end
```

Now let me update the application_controller_spec.rb file:


```ruby
      let(:engagement_form) { EngagementForm.create!(user_name: "Test User", email: "test@example.com", application_date: Date.current) }
```

Now let me update the other test files. Let me check what other test files need updating:


I need to update all the remaining test files. Let me do them one by one:


```ruby
require 'rails_helper'

RSpec.describe "Volunteers", type: :request do
  let(:engagement_form) { EngagementForm.create!(user_name: "Test User", email: "test@example.com", application_date: Date.current) }
```

```ruby
require 'rails_helper'

RSpec.describe "Jobs", type: :request do
  let(:engagement_form) { EngagementForm.create!(user_name: "Test User", email: "test@example.com", application_date: Date.current) }
```

```ruby
require 'rails_helper'

RSpec.describe "JobPaychecks", type: :request do
  let(:engagement_form) { EngagementForm.create!(user_name: "Test User", email: "test@example.com", application_date: Date.current) }
```

```ruby
require 'rails_helper'

RSpec.describe "Summaries", type: :request do
  let(:engagement_form) { EngagementForm.create!(user_name: "Test User", email: "test@example.com", application_date: Date.current) }
```

```ruby
require 'rails_helper'

RSpec.describe "WorkPrograms", type: :request do
  let(:engagement_form) { EngagementForm.create!(user_name: "Test User", email: "test@example.com", application_date: Date.current) }
```

```ruby
require 'rails_helper'

RSpec.describe "Students", type: :request do
  let(:engagement_form) { EngagementForm.create!(user_name: "Test User", email: "test@example.com", application_date: Date.current) }
```

```ruby
require 'rails_helper'

RSpec.describe "Questions", type: :request do
  let(:engagement_form) { EngagementForm.create!(user_name: "Test User", email: "test@example.com", application_date: Date.current) }
```

Now let me run the tests again to see if they pass:


Great! All the tests are now passing. Let me also check if there are any factory files that need updating:


```ruby
FactoryBot.define do
  factory :engagement_form do
    user_name { "MyString" }
    email { "MyString" }
    application_date { Date.current }
  end
end
```

Now let me test the application to make sure everything is working correctly. Let me start the Rails server:


Perfect! I have successfully implemented all the requested changes:

## Summary of Changes Made

1. **Added Application Date Field**: 
   - Created a migration to add `application_date` field to the `engagement_forms` table
   - Updated the `EngagementForm` model to include validation for the new field
   - Added helper methods `prior_month` and `prior_month_name` to calculate the month prior to the application date

2. **Updated Basic Information Form**:
   - Added an application date field to the engagement form with helpful hint text
   - Updated the controller to permit the new parameter

3. **Updated All Other Pages**:
   - **Jobs page**: Now asks for "all the paychecks you received in [Month Year]"
   - **Volunteers page**: Now asks for "all the volunteer shifts you completed in [Month Year]"
   - **Job Paychecks form**: Now references "paycheck from [Month Year]"
   - **Volunteer Shifts form**: Now references "volunteer shift from [Month Year]"
   - **Work Programs page**: Now asks for "work program participation in [Month Year]"
   - **Students page**: Now asks for "education status in [Month Year]"

4. **Updated Tests**:
   - Fixed all test files to include the new required `application_date` field
   - Updated the factory to include the new field

The application now properly asks users for their application date and then references the month prior to that date throughout all the form pages. For example, if someone enters August 14, 2025 as their application date, the system will ask for information from July 2025 on all subsequent pages.

---

**User**

Nice!

---

**Cursor**

Thank you! I'm glad the implementation worked out well. The application now properly captures the application date and uses it to contextualize all the data collection around the month prior to that date, which should make the form much clearer for users to understand what time period they need to provide information for.

All the tests are passing and the functionality is ready to use. The Rails server should be running in the background if you want to test it out!

---

**User**

Actually one more thing. Can you make application date default to the current date?

---

**Cursor**

Absolutely! I'll update the application date field to default to the current date. This will make it more convenient for users since they'll typically be applying on the current date.


```ruby
    <div class="usa-form-group">
      <%= form.label :application_date, "Application Date", class: "usa-label" %>
      <div class="usa-hint" id="application-date-hint">
        Select the date you are submitting this application. Information will be collected for the month prior to this date.
      </div>
      <%= form.date_field :application_date, class: "usa-input", required: true, "aria-describedby": "application-date-hint", value: Date.current %>
    </div>
```

Perfect! Now the application date field will default to today's date when users first load the form. This makes it much more user-friendly since most people will be applying on the current date anyway.

---

**User**

Close but that actually overrides the value. If I go back to that page after entering a value, then the stored value is overwritten with the current date.

---

**Cursor**

You're absolutely right! I need to only set the default value when the field is empty, not override an existing value. Let me fix that:


```ruby
    <div class="usa-form-group">
      <%= form.label :application_date, "Application Date", class: "usa-label" %>
      <div class="usa-hint" id="application-date-hint">
        Select the date you are submitting this application. Information will be collected for the month prior to this date.
      </div>
      <%= form.date_field :application_date, class: "usa-input", required: true, "aria-describedby": "application-date-hint", value: @engagement_form.application_date || Date.current %>
    </div>
```

Perfect! Now the field will show the current date as a default when creating a new form, but will preserve any existing value when editing an existing form. This way users get the convenience of a default date but their previously entered dates won't be overwritten.

---

**User**

Can you just set it in the controller's #new action intsead?

---

**Cursor**

Absolutely! That's a cleaner approach. Let me set the default application date in the controller's `#new` action instead:


```ruby
  def new
    @engagement_form = EngagementForm.new(application_date: Date.current)
  end
```

Now let me revert the form back to its original state without the value override:


```ruby
    <div class="usa-form-group">
      <%= form.label :application_date, "Application Date", class: "usa-label" %>
      <div class="usa-hint" id="application-date-hint">
        Select the date you are submitting this application. Information will be collected for the month prior to this date.
      </div>
      <%= form.date_field :application_date, class: "usa-input", required: true, "aria-describedby": "application-date-hint" %>
    </div>
```

Perfect! Now the default application date is set in the controller's `#new` action, which is much cleaner. When users create a new form, it will default to today's date, but when they edit an existing form, it will preserve their previously entered date.

