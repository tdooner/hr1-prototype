# Update questions controller UX
_Exported on 8/30/2025 at 12:43:05 PDT from Cursor (1.5.7)_

---

**User**

We're going to update the UX of the questions controller.

* Move the text in the informational "usa-alert" component to be outside an alert, just normal text on the page.

* Instead of asking the four questions as separate radio buttons, change it into four checkboxes next to each other. The label should be "Check any of these that apply:"

Update the controller as necessary to save the values the same way. And update tests.

---

**Cursor**

I'll help you update the UX of the questions controller. Let me first explore the codebase to understand the current structure and locate the relevant files.


Now let me look at the current questions view to understand the structure:


Now let me check the questions controller to understand how it currently handles the data:


Now let me check the tests to understand what needs to be updated:


Perfect! Now I understand the current structure. Let me implement the requested changes:

1. Move the informational text outside the alert component
2. Change the four radio button questions to checkboxes with the label "Check any of these that apply:"
3. Update the controller to handle checkbox values
4. Update the tests

Let me start with updating the view:


```ruby
<div class="grid-row">
  <div class="grid-col-12">
    <h1 class="usa-prose">Community Engagement Requirements</h1>
    
    <div class="usa-prose">
      <h3>Requirements Overview</h3>
      <p>
        To meet the Community Engagement Requirements, you must demonstrate either a certain amount of income or hours spent on qualifying activities. 
        Please answer the following questions to help determine which requirements apply to your situation.
      </p>
    </div>
    
    <%= form_with url: engagement_form_questions_path(@engagement_form), method: :post, local: true, class: "usa-form" do |form| %>
      
      <fieldset class="usa-fieldset">
        <legend class="usa-legend">Check any of these that apply:</legend>
        
        <div class="usa-checkbox">
          <%= form.check_box :has_job, { class: "usa-checkbox__input" }, "yes", "no" %>
          <%= form.label :has_job, "I have a job", class: "usa-checkbox__label" %>
        </div>
        
        <div class="usa-checkbox">
          <%= form.check_box :is_student, { class: "usa-checkbox__input" }, "yes", "no" %>
          <%= form.label :is_student, "I am a student", class: "usa-checkbox__label" %>
        </div>
        
        <div class="usa-checkbox">
          <%= form.check_box :enrolled_work_program, { class: "usa-checkbox__input" }, "yes", "no" %>
          <%= form.label :enrolled_work_program, "I am enrolled in a work program", class: "usa-checkbox__label" %>
        </div>
        
        <div class="usa-checkbox">
          <%= form.check_box :volunteers_nonprofit, { class: "usa-checkbox__input" }, "yes", "no" %>
          <%= form.label :volunteers_nonprofit, "I volunteer with a nonprofit organization", class: "usa-checkbox__label" %>
        </div>
      </fieldset>
      
      <div class="usa-form-group">
        <%= form.submit "Continue", class: "usa-button" %>
        <%= link_to "Back", new_engagement_form_path, class: "usa-button usa-button--outline" %>
      </div>
    <% end %>
  </div>
</div>
```

Now I need to update the controller to handle checkbox values properly. With checkboxes, the values will be "yes" when checked and "no" when unchecked, but I need to make sure the logic handles this correctly:


```ruby
class QuestionsController < ApplicationController
  def new
    @engagement_form = EngagementForm.find(params[:engagement_form_id])
  end

  def create
    @engagement_form = EngagementForm.find(params[:engagement_form_id])
    
    # Update the engagement form with the checkbox answers
    # Checkboxes return "yes" when checked, nil when unchecked
    @engagement_form.update(
      has_job: params[:has_job] == "yes",
      is_student: params[:is_student] == "yes",
      enrolled_work_program: params[:enrolled_work_program] == "yes",
      volunteers_nonprofit: params[:volunteers_nonprofit] == "yes"
    )
    
    # Determine the next step based on the answers
    next_step = determine_next_step(params)
    
    redirect_to next_step
  end
  
  private
  
  def determine_next_step(params)
    # Check each engagement type in order and route to the first one that's "yes"
    if params[:has_job] == "yes"
      new_engagement_form_job_path(@engagement_form)
    elsif params[:is_student] == "yes"
      new_engagement_form_student_path(@engagement_form)
    elsif params[:enrolled_work_program] == "yes"
      new_engagement_form_work_program_path(@engagement_form)
    elsif params[:volunteers_nonprofit] == "yes"
      new_engagement_form_volunteer_path(@engagement_form)
    else
      # If none are selected, go to summary
      summary_path(@engagement_form.id)
    end
  end
end
```

Now I need to update the tests to reflect the new checkbox behavior. The tests should check for the new structure and ensure the controller handles checkbox values correctly:


```ruby
require 'rails_helper'

RSpec.describe "Questions", type: :request do
  let(:engagement_form) { EngagementForm.create!(user_name: "Test User", email: "test@example.com", organization: "Test Org") }

  describe "GET /new" do
    it "returns http success" do
      get "/engagement_forms/#{engagement_form.id}/questions/new"
      expect(response).to have_http_status(:success)
    end

    it "displays the questions form with checkboxes" do
      get "/engagement_forms/#{engagement_form.id}/questions/new"
      expect(response.body).to include("Check any of these that apply:")
      expect(response.body).to include("I have a job")
      expect(response.body).to include("I am a student")
      expect(response.body).to include("I am enrolled in a work program")
      expect(response.body).to include("I volunteer with a nonprofit organization")
    end

    it "displays informational text outside of alert component" do
      get "/engagement_forms/#{engagement_form.id}/questions/new"
      expect(response.body).to include("Requirements Overview")
      expect(response.body).to include("To meet the Community Engagement Requirements")
      expect(response.body).not_to include("usa-alert")
    end
  end

  describe "POST /create" do
    it "handles no selections and redirects to summary" do
      post "/engagement_forms/#{engagement_form.id}/questions", params: {}
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(summary_path(engagement_form.id))
    end

    it "handles job selection and redirects to job form" do
      post "/engagement_forms/#{engagement_form.id}/questions", params: { has_job: "yes" }
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(new_engagement_form_job_path(engagement_form))
    end

    it "handles student selection and redirects to student form" do
      post "/engagement_forms/#{engagement_form.id}/questions", params: { is_student: "yes" }
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(new_engagement_form_student_path(engagement_form))
    end

    it "handles work program selection and redirects to work program form" do
      post "/engagement_forms/#{engagement_form.id}/questions", params: { enrolled_work_program: "yes" }
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(new_engagement_form_work_program_path(engagement_form))
    end

    it "handles volunteer selection and redirects to volunteer form" do
      post "/engagement_forms/#{engagement_form.id}/questions", params: { volunteers_nonprofit: "yes" }
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(new_engagement_form_volunteer_path(engagement_form))
    end

    it "prioritizes job over other selections" do
      post "/engagement_forms/#{engagement_form.id}/questions", params: { 
        has_job: "yes", 
        is_student: "yes", 
        enrolled_work_program: "yes", 
        volunteers_nonprofit: "yes" 
      }
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(new_engagement_form_job_path(engagement_form))
    end

    it "updates engagement form with correct boolean values" do
      post "/engagement_forms/#{engagement_form.id}/questions", params: { 
        has_job: "yes", 
        is_student: "yes" 
      }
      
      engagement_form.reload
      expect(engagement_form.has_job).to be true
      expect(engagement_form.is_student).to be true
      expect(engagement_form.enrolled_work_program).to be false
      expect(engagement_form.volunteers_nonprofit).to be false
    end
  end
end
```

Now let's run the tests to make sure everything is working correctly:


Let me run the tests with more verbose output to see the results:


Excellent! All the tests are passing. Let me also run a broader test to make sure I haven't broken anything else:


Perfect! All tests are passing. Let me also start the Rails server to verify the changes work correctly in the browser:


Great! I've successfully updated the UX of the questions controller according to your requirements. Here's a summary of the changes made:

## Changes Made

### 1. **Updated the View (`app/views/questions/new.html.erb`)**
- **Moved informational text outside the alert**: The "Requirements Overview" text is now displayed as normal text using the `usa-prose` class instead of being wrapped in a `usa-alert` component
- **Changed radio buttons to checkboxes**: All four questions are now presented as checkboxes in a single fieldset with the label "Check any of these that apply:"
- **Simplified question labels**: Removed the "Yes/No" format and made the labels more direct (e.g., "I have a job" instead of "Yes, I have a job")

### 2. **Updated the Controller (`app/controllers/questions_controller.rb`)**
- **Updated comments**: Changed the comment to reflect that we're now handling checkbox values instead of radio button values
- **Maintained the same logic**: The controller still processes the values the same way - "yes" values are converted to `true`, and missing/nil values are converted to `false`
- **Preserved routing logic**: The conditional routing based on user selections remains unchanged

### 3. **Updated the Tests (`spec/requests/questions_spec.rb`)**
- **Added comprehensive test coverage**: Tests now verify the new checkbox interface and informational text display
- **Tested all scenarios**: Added tests for no selections, individual selections, multiple selections, and priority routing
- **Verified data persistence**: Added a test to ensure the engagement form is updated with correct boolean values
- **Tested UI elements**: Added tests to verify the presence of the new label and absence of the alert component

## Key Benefits

1. **Better UX**: Users can now select multiple options if they apply, rather than being forced to choose one
2. **Cleaner interface**: The informational text is now part of the normal page flow rather than being highlighted in an alert
3. **More intuitive**: The "Check any of these that apply:" label makes it clear that multiple selections are possible
4. **Maintained functionality**: All existing routing and data saving logic continues to work as expected

## Testing Results

- ✅ All 10 questions controller tests pass
- ✅ All 44 total application tests pass
- ✅ No breaking changes to existing functionality

The Rails server is now running and you can test the updated interface at `http://localhost:3000`. The questions page will now show the informational text as normal text and present the four engagement type questions as checkboxes that users can select multiple options from.

---

**User**

Great. Now, let's update the UX of the summary page. I'd like to add one more step where the user can review all their answers and click a "Submit" button to complete the process. The "Download PDF" button is only available after the form is completed. The review page should also include links to edit each individual response by going back to the corresponding page.

---

**Cursor**

I'll help you update the UX of the summary page to add a review step before final submission. Let me first examine the current summary page structure and then implement the changes.


Now let me look at the current summary view:


Now let me check the EngagementForm model to see if there's a field to track completion status:


Now I need to add a field to track the completion status. Let me create a migration to add a `completed` field:


Now I need to add routes for the review and submit actions. Let me update the routes:


```ruby
Rails.application.routes.draw do
  # Community Engagement Form flow
  resources :engagement_forms, only: [:new, :create, :show] do
    member do
      get :pdf
    end
    
    # Nested resources that require engagement_form_id
    resources :questions, only: [:new, :create]
    resources :jobs, only: [:new, :create]
    resources :students, only: [:new, :create]
    resources :work_programs, only: [:new, :create]
    resources :volunteers, only: [:new, :create]
  end
  
  # Summary pages
  get "summary/:engagement_form_id", to: "summary#show", as: :summary
  get "summary/:engagement_form_id/review", to: "summary#review", as: :review_summary
  post "summary/:engagement_form_id/submit", to: "summary#submit", as: :submit_summary
  
  # Root route
  root "engagement_forms#new"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
```

Now I need to update the summary controller to handle the review and submit actions:


```ruby
class SummaryController < ApplicationController
  def show
    @engagement_form = EngagementForm.find(params[:engagement_form_id])
    
    # If the form is not completed, redirect to the review page
    unless @engagement_form.completed?
      redirect_to review_summary_path(@engagement_form)
      return
    end
  end

  def review
    @engagement_form = EngagementForm.find(params[:engagement_form_id])
  end

  def submit
    @engagement_form = EngagementForm.find(params[:engagement_form_id])
    
    # Mark the form as completed
    @engagement_form.update(completed: true)
    
    # Redirect to the final summary page
    redirect_to summary_path(@engagement_form), notice: 'Form submitted successfully!'
  end
end
```

Now I need to create the review view. Let me create the review template:


```ruby
<div class="grid-row">
  <div class="grid-col-12">
    <h1 class="usa-prose">Review Your Community Engagement Form</h1>
    
    <div class="usa-alert usa-alert--info" role="alert">
      <div class="usa-alert__body">
        <h3 class="usa-alert__heading">Please Review Your Information</h3>
        <p class="usa-alert__text">
          Please review all your responses below. You can edit any section by clicking the "Edit" link next to it. 
          Once you're satisfied with your answers, click "Submit Form" to complete the process.
        </p>
      </div>
    </div>
    
    <div class="usa-summary-box">
      <div class="usa-summary-box__body">
        <h3 class="usa-summary-box__heading">
          Basic Information
          <%= link_to "Edit", new_engagement_form_path, class: "usa-button usa-button--small usa-button--outline", style: "float: right;" %>
        </h3>
        <div class="usa-summary-box__text">
          <p><strong>Name:</strong> <%= @engagement_form.user_name %></p>
          <p><strong>Email:</strong> <%= @engagement_form.email %></p>
          <p><strong>Organization:</strong> <%= @engagement_form.organization %></p>
        </div>
      </div>
    </div>
    
    <div class="usa-summary-box">
      <div class="usa-summary-box__body">
        <h3 class="usa-summary-box__heading">
          Engagement Activities
          <%= link_to "Edit", new_engagement_form_question_path(@engagement_form), class: "usa-button usa-button--small usa-button--outline", style: "float: right;" %>
        </h3>
        <div class="usa-summary-box__text">
          <ul class="usa-list">
            <li><%= @engagement_form.has_job? ? "✅ I have a job" : "❌ I don't have a job" %></li>
            <li><%= @engagement_form.is_student? ? "✅ I am a student" : "❌ I am not a student" %></li>
            <li><%= @engagement_form.enrolled_work_program? ? "✅ I am enrolled in a work program" : "❌ I am not enrolled in a work program" %></li>
            <li><%= @engagement_form.volunteers_nonprofit? ? "✅ I volunteer with a nonprofit organization" : "❌ I don't volunteer with a nonprofit organization" %></li>
          </ul>
        </div>
      </div>
    </div>
    
    <% if @engagement_form.has_job? %>
      <div class="usa-summary-box">
        <div class="usa-summary-box__body">
          <h3 class="usa-summary-box__heading">
            Employment Details
            <%= link_to "Edit", new_engagement_form_job_path(@engagement_form), class: "usa-button usa-button--small usa-button--outline", style: "float: right;" %>
          </h3>
          <div class="usa-summary-box__text">
            <p><%= @engagement_form.job_details %></p>
          </div>
        </div>
      </div>
    <% end %>
    
    <% if @engagement_form.is_student? %>
      <div class="usa-summary-box">
        <div class="usa-summary-box__body">
          <h3 class="usa-summary-box__heading">
            Student Details
            <%= link_to "Edit", new_engagement_form_student_path(@engagement_form), class: "usa-button usa-button--small usa-button--outline", style: "float: right;" %>
          </h3>
          <div class="usa-summary-box__text">
            <p><%= @engagement_form.student_details %></p>
          </div>
        </div>
      </div>
    <% end %>
    
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
    
    <% if @engagement_form.volunteers_nonprofit? %>
      <div class="usa-summary-box">
        <div class="usa-summary-box__body">
          <h3 class="usa-summary-box__heading">
            Volunteer Details
            <%= link_to "Edit", new_engagement_form_volunteer_path(@engagement_form), class: "usa-button usa-button--small usa-button--outline", style: "float: right;" %>
          </h3>
          <div class="usa-summary-box__text">
            <p><%= @engagement_form.volunteer_details %></p>
          </div>
        </div>
      </div>
    <% end %>
    
    <% if !@engagement_form.has_job? && !@engagement_form.is_student? && !@engagement_form.enrolled_work_program? && !@engagement_form.volunteers_nonprofit? %>
      <div class="usa-alert usa-alert--warning" role="alert">
        <div class="usa-alert__body">
          <h3 class="usa-alert__heading">No Engagement Activities Selected</h3>
          <p class="usa-alert__text">You indicated that you do not participate in any of the qualifying engagement activities. Please review the Community Engagement Requirements to ensure you meet the necessary criteria.</p>
        </div>
      </div>
    <% end %>
    
    <div class="usa-form-group">
      <%= form_with url: submit_summary_path(@engagement_form), method: :post, local: true do |form| %>
        <%= form.submit "Submit Form", class: "usa-button" %>
      <% end %>
      <%= link_to "Back to Questions", new_engagement_form_question_path(@engagement_form), class: "usa-button usa-button--outline" %>
    </div>
  </div>
</div>
```

Now I need to update the final summary view to show the completion message and only show the PDF download after submission:


```ruby
<div class="grid-row">
  <div class="grid-col-12">
    <h1 class="usa-prose">Community Engagement Form Summary</h1>
    
    <% if @engagement_form.completed? %>
      <div class="usa-alert usa-alert--success" role="alert">
        <div class="usa-alert__body">
          <h3 class="usa-alert__heading">Form Submitted Successfully!</h3>
          <p class="usa-alert__text">Your community engagement form has been submitted and is now complete. Below is a summary of your responses.</p>
        </div>
      </div>
    <% end %>
    
    <div class="usa-summary-box">
      <div class="usa-summary-box__body">
        <h3 class="usa-summary-box__heading">Basic Information</h3>
        <div class="usa-summary-box__text">
          <p><strong>Name:</strong> <%= @engagement_form.user_name %></p>
          <p><strong>Email:</strong> <%= @engagement_form.email %></p>
          <p><strong>Organization:</strong> <%= @engagement_form.organization %></p>
        </div>
      </div>
    </div>
    
    <h2 class="usa-prose">Engagement Activities</h2>
    
    <% if @engagement_form.has_job? %>
      <div class="usa-summary-box">
        <div class="usa-summary-box__body">
          <h3 class="usa-summary-box__heading">✅ Employment</h3>
          <div class="usa-summary-box__text">
            <p><%= @engagement_form.job_details %></p>
          </div>
        </div>
      </div>
    <% end %>
    
    <% if @engagement_form.is_student? %>
      <div class="usa-summary-box">
        <div class="usa-summary-box__body">
          <h3 class="usa-summary-box__heading">✅ Student Status</h3>
          <div class="usa-summary-box__text">
            <p><%= @engagement_form.student_details %></p>
          </div>
        </div>
      </div>
    <% end %>
    
    <% if @engagement_form.enrolled_work_program? %>
      <div class="usa-summary-box">
        <div class="usa-summary-box__body">
          <h3 class="usa-summary-box__heading">✅ Work Program</h3>
          <div class="usa-summary-box__text">
            <p><%= @engagement_form.work_program_details %></p>
          </div>
        </div>
      </div>
    <% end %>
    
    <% if @engagement_form.volunteers_nonprofit? %>
      <div class="usa-summary-box">
        <div class="usa-summary-box__body">
          <h3 class="usa-summary-box__heading">✅ Volunteer Work</h3>
          <div class="usa-summary-box__text">
            <p><%= @engagement_form.volunteer_details %></p>
          </div>
        </div>
      </div>
    <% end %>
    
    <% if !@engagement_form.has_job? && !@engagement_form.is_student? && !@engagement_form.enrolled_work_program? && !@engagement_form.volunteers_nonprofit? %>
      <div class="usa-alert usa-alert--warning" role="alert">
        <div class="usa-alert__body">
          <h3 class="usa-alert__heading">No Engagement Activities Selected</h3>
          <p class="usa-alert__text">You indicated that you do not participate in any of the qualifying engagement activities. Please review the Community Engagement Requirements to ensure you meet the necessary criteria.</p>
        </div>
      </div>
    <% end %>
    
    <div class="usa-form-group">
      <% if @engagement_form.completed? %>
        <%= link_to "Download PDF", engagement_form_path(@engagement_form, format: :pdf), class: "usa-button" %>
      <% end %>
      <%= link_to "Submit Another Form", new_engagement_form_path, class: "usa-button usa-button--outline" %>
    </div>
  </div>
</div>
```

Now I need to update the detail controllers to redirect to the review page instead of the summary page. Let me update the volunteers controller first (since it's the last one):


```ruby
class VolunteersController < ApplicationController
  def new
    @engagement_form = EngagementForm.find(params[:engagement_form_id])
  end

  def create
    @engagement_form = EngagementForm.find(params[:engagement_form_id])
    
    @engagement_form.update(volunteer_details: params[:volunteer_details])
    
    # Go to review page since this is the last step
    redirect_to review_summary_path(@engagement_form.id)
  end
end
```

Now I need to update the other detail controllers to redirect to the review page if there are no more steps. Let me check the students controller:


```ruby
class StudentsController < ApplicationController
  def new
    @engagement_form = EngagementForm.find(params[:engagement_form_id])
  end

  def create
    @engagement_form = EngagementForm.find(params[:engagement_form_id])
    
    @engagement_form.update(student_details: params[:student_details])
    
    # Determine next step based on remaining engagement types
    next_step = determine_next_step
    
    redirect_to next_step
  end
  
  private
  
  def determine_next_step
    if @engagement_form.enrolled_work_program?
      new_engagement_form_work_program_path(@engagement_form)
    elsif @engagement_form.volunteers_nonprofit?
      new_engagement_form_volunteer_path(@engagement_form)
    else
      review_summary_path(@engagement_form.id)
    end
  end
end
```

Now let me update the jobs controller:


```ruby
class JobsController < ApplicationController
  def new
    @engagement_form = EngagementForm.find(params[:engagement_form_id])
  end

  def create
    @engagement_form = EngagementForm.find(params[:engagement_form_id])
    
    @engagement_form.update(job_details: params[:job_details])
    
    # Determine next step based on remaining engagement types
    next_step = determine_next_step
    
    redirect_to next_step
  end
  
  private
  
  def determine_next_step
    if @engagement_form.is_student?
      new_engagement_form_student_path(@engagement_form)
    elsif @engagement_form.enrolled_work_program?
      new_engagement_form_work_program_path(@engagement_form)
    elsif @engagement_form.volunteers_nonprofit?
      new_engagement_form_volunteer_path(@engagement_form)
    else
      review_summary_path(@engagement_form.id)
    end
  end
end
```

Now let me check if there's a work_programs controller and update it:


```ruby
class WorkProgramsController < ApplicationController
  def new
    @engagement_form = EngagementForm.find(params[:engagement_form_id])
  end

  def create
    @engagement_form = EngagementForm.find(params[:engagement_form_id])
    
    @engagement_form.update(work_program_details: params[:work_program_details])
    
    # Determine next step based on remaining engagement types
    next_step = determine_next_step
    
    redirect_to next_step
  end
  
  private
  
  def determine_next_step
    if @engagement_form.volunteers_nonprofit?
      new_engagement_form_volunteer_path(@engagement_form)
    else
      review_summary_path(@engagement_form.id)
    end
  end
end
```

Now I need to update the questions controller to redirect to the review page if no engagement types are selected:


```ruby
class QuestionsController < ApplicationController
  def new
    @engagement_form = EngagementForm.find(params[:engagement_form_id])
  end

  def create
    @engagement_form = EngagementForm.find(params[:engagement_form_id])
    
    # Update the engagement form with the checkbox answers
    # Checkboxes return "yes" when checked, nil when unchecked
    @engagement_form.update(
      has_job: params[:has_job] == "yes",
      is_student: params[:is_student] == "yes",
      enrolled_work_program: params[:enrolled_work_program] == "yes",
      volunteers_nonprofit: params[:volunteers_nonprofit] == "yes"
    )
    
    # Determine the next step based on the answers
    next_step = determine_next_step(params)
    
    redirect_to next_step
  end
  
  private
  
  def determine_next_step(params)
    # Check each engagement type in order and route to the first one that's "yes"
    if params[:has_job] == "yes"
      new_engagement_form_job_path(@engagement_form)
    elsif params[:is_student] == "yes"
      new_engagement_form_student_path(@engagement_form)
    elsif params[:enrolled_work_program] == "yes"
      new_engagement_form_work_program_path(@engagement_form)
    elsif params[:volunteers_nonprofit] == "yes"
      new_engagement_form_volunteer_path(@engagement_form)
    else
      # If none are selected, go to review page
      review_summary_path(@engagement_form.id)
    end
  end
end
```

Now I need to update the tests to reflect the new flow. Let me update the summary tests:


```ruby
require 'rails_helper'

RSpec.describe "Summaries", type: :request do
  let(:engagement_form) { EngagementForm.create!(user_name: "Test User", email: "test@example.com", organization: "Test Org") }

  describe "GET /show" do
    it "returns http success for completed form" do
      engagement_form.update(completed: true)
      get "/summary/#{engagement_form.id}"
      expect(response).to have_http_status(:success)
    end

    it "redirects to review page for incomplete form" do
      get "/summary/#{engagement_form.id}"
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(review_summary_path(engagement_form))
    end
  end

  describe "GET /review" do
    it "returns http success" do
      get "/summary/#{engagement_form.id}/review"
      expect(response).to have_http_status(:success)
    end

    it "displays the review form with edit links" do
      get "/summary/#{engagement_form.id}/review"
      expect(response.body).to include("Review Your Community Engagement Form")
      expect(response.body).to include("Edit")
      expect(response.body).to include("Submit Form")
    end
  end

  describe "POST /submit" do
    it "marks form as completed and redirects to summary" do
      post "/summary/#{engagement_form.id}/submit"
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(summary_path(engagement_form))
      
      engagement_form.reload
      expect(engagement_form.completed?).to be true
    end
  end
end
```

Now I need to update the questions controller tests to reflect the new redirect behavior:


```ruby
require 'rails_helper'

RSpec.describe "Questions", type: :request do
  let(:engagement_form) { EngagementForm.create!(user_name: "Test User", email: "test@example.com", organization: "Test Org") }

  describe "GET /new" do
    it "returns http success" do
      get "/engagement_forms/#{engagement_form.id}/questions/new"
      expect(response).to have_http_status(:success)
    end

    it "displays the questions form with checkboxes" do
      get "/engagement_forms/#{engagement_form.id}/questions/new"
      expect(response.body).to include("Check any of these that apply:")
      expect(response.body).to include("I have a job")
      expect(response.body).to include("I am a student")
      expect(response.body).to include("I am enrolled in a work program")
      expect(response.body).to include("I volunteer with a nonprofit organization")
    end

    it "displays informational text outside of alert component" do
      get "/engagement_forms/#{engagement_form.id}/questions/new"
      expect(response.body).to include("Requirements Overview")
      expect(response.body).to include("To meet the Community Engagement Requirements")
      expect(response.body).not_to include("usa-alert")
    end
  end

  describe "POST /create" do
    it "handles no selections and redirects to review page" do
      post "/engagement_forms/#{engagement_form.id}/questions", params: {}
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(review_summary_path(engagement_form.id))
    end

    it "handles job selection and redirects to job form" do
      post "/engagement_forms/#{engagement_form.id}/questions", params: { has_job: "yes" }
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(new_engagement_form_job_path(engagement_form))
    end

    it "handles student selection and redirects to student form" do
      post "/engagement_forms/#{engagement_form.id}/questions", params: { is_student: "yes" }
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(new_engagement_form_student_path(engagement_form))
    end

    it "handles work program selection and redirects to work program form" do
      post "/engagement_forms/#{engagement_form.id}/questions", params: { enrolled_work_program: "yes" }
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(new_engagement_form_work_program_path(engagement_form))
    end

    it "handles volunteer selection and redirects to volunteer form" do
      post "/engagement_forms/#{engagement_form.id}/questions", params: { volunteers_nonprofit: "yes" }
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(new_engagement_form_volunteer_path(engagement_form))
    end

    it "prioritizes job over other selections" do
      post "/engagement_forms/#{engagement_form.id}/questions", params: { 
        has_job: "yes", 
        is_student: "yes", 
        enrolled_work_program: "yes", 
        volunteers_nonprofit: "yes" 
      }
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(new_engagement_form_job_path(engagement_form))
    end

    it "updates engagement form with correct boolean values" do
      post "/engagement_forms/#{engagement_form.id}/questions", params: { 
        has_job: "yes", 
        is_student: "yes" 
      }
      
      engagement_form.reload
      expect(engagement_form.has_job).to be true
      expect(engagement_form.is_student).to be true
      expect(engagement_form.enrolled_work_program).to be false
      expect(engagement_form.volunteers_nonprofit).to be false
    end
  end
end
```

Now let me run the tests to make sure everything is working correctly:


Excellent! All tests are passing. Let me also run a broader test to make sure I haven't broken anything else:


Perfect! All tests are passing. Let me start the Rails server to test the new flow:


Excellent! I've successfully updated the UX of the summary page according to your requirements. Here's a summary of the changes made:

## Changes Made

### 1. **Added Database Field**
- **New `completed` field**: Added a boolean field to track whether the form has been submitted
- **Migration**: Created and ran migration to add the `completed` field to the `engagement_forms` table

### 2. **Updated Routes**
- **New review route**: `GET /summary/:engagement_form_id/review` - Shows the review page
- **New submit route**: `POST /summary/:engagement_form_id/submit` - Handles form submission
- **Updated existing routes**: Maintained backward compatibility with existing summary route

### 3. **Enhanced Summary Controller**
- **`show` action**: Now checks if form is completed and redirects to review if not
- **`review` action**: New action to display the review page
- **`submit` action**: New action to mark form as completed and redirect to final summary

### 4. **Created Review Page (`app/views/summary/review.html.erb`)**
- **Comprehensive review**: Shows all user responses in organized sections
- **Edit links**: Each section has an "Edit" button that links back to the corresponding form page
- **Submit button**: Prominent "Submit Form" button to complete the process
- **Clear instructions**: Informational alert explaining the review process

### 5. **Updated Final Summary Page (`app/views/summary/show.html.erb`)**
- **Conditional completion message**: Only shows success message after form is submitted
- **Conditional PDF download**: PDF download button only appears after form completion
- **Maintained existing functionality**: All other summary information remains the same

### 6. **Updated Flow Logic**
- **All detail controllers**: Now redirect to review page instead of summary when no more steps remain
- **Questions controller**: Redirects to review page if no engagement types are selected
- **Consistent flow**: Users always go through review before final submission

### 7. **Enhanced Tests**
- **Comprehensive test coverage**: Added tests for review and submit functionality
- **Updated existing tests**: Modified tests to reflect new redirect behavior
- **All tests passing**: 48 examples, 0 failures

## New User Flow

1. **Initial Form** → Basic information (name, email, organization)
2. **Questions Page** → Select engagement types (checkboxes)
3. **Detail Pages** → Fill in details for selected engagement types
4. **Review Page** → Review all answers with edit links
5. **Submit** → Click "Submit Form" to complete
6. **Final Summary** → View completed form with PDF download option

## Key Benefits

1. **Better User Experience**: Users can review and edit their responses before final submission
2. **Clear Completion State**: Form completion is explicitly tracked and communicated
3. **Edit Functionality**: Easy access to edit any section from the review page
4. **Controlled PDF Access**: PDF download only available after form completion
5. **Maintained Functionality**: All existing features continue to work as expected

The Rails server is now running and you can test the complete new flow at `http://localhost:3000`. Users will now go through a review step before final submission, and the PDF download will only be available after the form is completed.

---

**User**

Ok great. I noticed when I return to the various pages, the form is not populated with my previous answers. Can you fix that by using the existing object as you construct the Rails form?

---

**Cursor**

You're absolutely right! The forms aren't being populated with the existing data when users go back to edit their responses. Let me fix this by updating the form helpers to use the existing `@engagement_form` object data.

Let me first check the current volunteer form to see how it's structured:


I can see the issue! The form is using `form_with url:` instead of `form_with model:`, which means it's not bound to the `@engagement_form` object. Let me check the other detail forms and fix them all:


Now I need to update all these forms to use `form_with model:` instead of `form_with url:` so they'll be populated with existing data. Let me start with the volunteers form:


```ruby
<div class="grid-row">
  <div class="grid-col-12">
    <h1 class="usa-prose">Volunteer Details</h1>
    
    <p class="usa-intro">
      Please provide details about your volunteer work to help verify that you meet the Community Engagement Requirements.
    </p>
    
    <%= form_with model: @engagement_form, url: engagement_form_volunteers_path(@engagement_form), method: :post, local: true, class: "usa-form" do |form| %>
      
      <fieldset class="usa-fieldset">
        <legend class="usa-legend">Volunteer Details</legend>
        
        <div class="usa-form-group">
          <%= form.label :volunteer_details, "Please provide details about your volunteer work:", class: "usa-label" %>
          <div class="usa-hint" id="volunteer-details-hint">
            Include the nonprofit organization name, type of volunteer work, hours volunteered per week, and duration of involvement.
          </div>
          <%= form.text_area :volunteer_details, class: "usa-textarea", rows: 4, "aria-describedby": "volunteer-details-hint" %>
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

```ruby
<div class="grid-row">
  <div class="grid-col-12">
    <h1 class="usa-prose">Employment Details</h1>
    
    <p class="usa-intro">
      Please provide details about your employment to help verify that you meet the Community Engagement Requirements.
    </p>
    
    <%= form_with model: @engagement_form, url: engagement_form_jobs_path(@engagement_form), method: :post, local: true, class: "usa-form" do |form| %>
      
      <fieldset class="usa-fieldset">
        <legend class="usa-legend">Employment Details</legend>
        
        <div class="usa-form-group">
          <%= form.label :job_details, "Please provide details about your employment:", class: "usa-label" %>
          <div class="usa-hint" id="job-details-hint">
            Include your job title, employer name, hours worked per week, and income information.
          </div>
          <%= form.text_area :job_details, class: "usa-textarea", rows: 4, "aria-describedby": "job-details-hint" %>
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

```ruby
<div class="grid-row">
  <div class="grid-col-12">
    <h1 class="usa-prose">Student Details</h1>
    
    <p class="usa-intro">
      Please provide details about your education to help verify that you meet the Community Engagement Requirements.
    </p>
    
    <%= form_with model: @engagement_form, url: engagement_form_students_path(@engagement_form), method: :post, local: true, class: "usa-form" do |form| %>
      
      <fieldset class="usa-fieldset">
        <legend class="usa-legend">Student Details</legend>
        
        <div class="usa-form-group">
          <%= form.label :student_details, "Please provide details about your education:", class: "usa-label" %>
          <div class="usa-hint" id="student-details-hint">
            Include your school/institution name, program of study, enrollment status, and hours spent on coursework.
          </div>
          <%= form.text_area :student_details, class: "usa-textarea", rows: 4, "aria-describedby": "student-details-hint" %>
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

```ruby
<div class="grid-row">
  <div class="grid-col-12">
    <h1 class="usa-prose">Work Program Details</h1>
    
    <p class="usa-intro">
      Please provide details about your work program to help verify that you meet the Community Engagement Requirements.
    </p>
    
    <%= form_with model: @engagement_form, url: engagement_form_work_programs_path(@engagement_form), method: :post, local: true, class: "usa-form" do |form| %>
      
      <fieldset class="usa-fieldset">
        <legend class="usa-legend">Work Program Details</legend>
        
        <div class="usa-form-group">
          <%= form.label :work_program_details, "Please provide details about your work program:", class: "usa-label" %>
          <div class="usa-hint" id="work-program-details-hint">
            Include the program name, organization providing the program, hours spent in the program, and any income received.
          </div>
          <%= form.text_area :work_program_details, class: "usa-textarea", rows: 4, "aria-describedby": "work-program-details-hint" %>
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

Now I need to check if the questions form also needs to be updated to show the existing checkbox selections:


Yes, the questions form also needs to be updated to use `form_with model:` so the checkboxes will show the existing selections:


```ruby
<div class="grid-row">
  <div class="grid-col-12">
    <h1 class="usa-prose">Community Engagement Requirements</h1>
    
    <div class="usa-prose">
      <h3>Requirements Overview</h3>
      <p>
        To meet the Community Engagement Requirements, you must demonstrate either a certain amount of income or hours spent on qualifying activities. 
        Please answer the following questions to help determine which requirements apply to your situation.
      </p>
    </div>
    
    <%= form_with model: @engagement_form, url: engagement_form_questions_path(@engagement_form), method: :post, local: true, class: "usa-form" do |form| %>
      
      <fieldset class="usa-fieldset">
        <legend class="usa-legend">Check any of these that apply:</legend>
        
        <div class="usa-checkbox">
          <%= form.check_box :has_job, { class: "usa-checkbox__input" }, "yes", "no" %>
          <%= form.label :has_job, "I have a job", class: "usa-checkbox__label" %>
        </div>
        
        <div class="usa-checkbox">
          <%= form.check_box :is_student, { class: "usa-checkbox__input" }, "yes", "no" %>
          <%= form.label :is_student, "I am a student", class: "usa-checkbox__label" %>
        </div>
        
        <div class="usa-checkbox">
          <%= form.check_box :enrolled_work_program, { class: "usa-checkbox__input" }, "yes", "no" %>
          <%= form.label :enrolled_work_program, "I am enrolled in a work program", class: "usa-checkbox__label" %>
        </div>
        
        <div class="usa-checkbox">
          <%= form.check_box :volunteers_nonprofit, { class: "usa-checkbox__input" }, "yes", "no" %>
          <%= form.label :volunteers_nonprofit, "I volunteer with a nonprofit organization", class: "usa-checkbox__label" %>
        </div>
      </fieldset>
      
      <div class="usa-form-group">
        <%= form.submit "Continue", class: "usa-button" %>
        <%= link_to "Back", new_engagement_form_path, class: "usa-button usa-button--outline" %>
      </div>
    <% end %>
  </div>
</div>
```

Now I need to update the controllers to handle the form parameters correctly. The issue is that when using `form_with model:`, Rails will send the parameters nested under the model name. Let me update the controllers to handle this:


```ruby
class VolunteersController < ApplicationController
  def new
    @engagement_form = EngagementForm.find(params[:engagement_form_id])
  end

  def create
    @engagement_form = EngagementForm.find(params[:engagement_form_id])
    
    # Handle both nested and direct parameters
    volunteer_details = params[:engagement_form]&.dig(:volunteer_details) || params[:volunteer_details]
    @engagement_form.update(volunteer_details: volunteer_details)
    
    # Go to review page since this is the last step
    redirect_to review_summary_path(@engagement_form.id)
  end
end
```

```ruby
class JobsController < ApplicationController
  def new
    @engagement_form = EngagementForm.find(params[:engagement_form_id])
  end

  def create
    @engagement_form = EngagementForm.find(params[:engagement_form_id])
    
    # Handle both nested and direct parameters
    job_details = params[:engagement_form]&.dig(:job_details) || params[:job_details]
    @engagement_form.update(job_details: job_details)
    
    # Determine next step based on remaining engagement types
    next_step = determine_next_step
    
    redirect_to next_step
  end
  
  private
  
  def determine_next_step
    if @engagement_form.is_student?
      new_engagement_form_student_path(@engagement_form)
    elsif @engagement_form.enrolled_work_program?
      new_engagement_form_work_program_path(@engagement_form)
    elsif @engagement_form.volunteers_nonprofit?
      new_engagement_form_volunteer_path(@engagement_form)
    else
      review_summary_path(@engagement_form.id)
    end
  end
end
```

```ruby
class StudentsController < ApplicationController
  def new
    @engagement_form = EngagementForm.find(params[:engagement_form_id])
  end

  def create
    @engagement_form = EngagementForm.find(params[:engagement_form_id])
    
    # Handle both nested and direct parameters
    student_details = params[:engagement_form]&.dig(:student_details) || params[:student_details]
    @engagement_form.update(student_details: student_details)
    
    # Determine next step based on remaining engagement types
    next_step = determine_next_step
    
    redirect_to next_step
  end
  
  private
  
  def determine_next_step
    if @engagement_form.enrolled_work_program?
      new_engagement_form_work_program_path(@engagement_form)
    elsif @engagement_form.volunteers_nonprofit?
      new_engagement_form_volunteer_path(@engagement_form)
    else
      review_summary_path(@engagement_form.id)
    end
  end
end
```

```ruby
class WorkProgramsController < ApplicationController
  def new
    @engagement_form = EngagementForm.find(params[:engagement_form_id])
  end

  def create
    @engagement_form = EngagementForm.find(params[:engagement_form_id])
    
    # Handle both nested and direct parameters
    work_program_details = params[:engagement_form]&.dig(:work_program_details) || params[:work_program_details]
    @engagement_form.update(work_program_details: work_program_details)
    
    # Determine next step based on remaining engagement types
    next_step = determine_next_step
    
    redirect_to next_step
  end
  
  private
  
  def determine_next_step
    if @engagement_form.volunteers_nonprofit?
      new_engagement_form_volunteer_path(@engagement_form)
    else
      review_summary_path(@engagement_form.id)
    end
  end
end
```

```ruby
class QuestionsController < ApplicationController
  def new
    @engagement_form = EngagementForm.find(params[:engagement_form_id])
  end

  def create
    @engagement_form = EngagementForm.find(params[:engagement_form_id])
    
    # Handle both nested and direct parameters
    engagement_params = params[:engagement_form] || params
    
    # Update the engagement form with the checkbox answers
    # Checkboxes return "yes" when checked, nil when unchecked
    @engagement_form.update(
      has_job: engagement_params[:has_job] == "yes",
      is_student: engagement_params[:is_student] == "yes",
      enrolled_work_program: engagement_params[:enrolled_work_program] == "yes",
      volunteers_nonprofit: engagement_params[:volunteers_nonprofit] == "yes"
    )
    
    # Determine the next step based on the answers
    next_step = determine_next_step(engagement_params)
    
    redirect_to next_step
  end
  
  private
  
  def determine_next_step(params)
    # Check each engagement type in order and route to the first one that's "yes"
    if params[:has_job] == "yes"
      new_engagement_form_job_path(@engagement_form)
    elsif params[:is_student] == "yes"
      new_engagement_form_student_path(@engagement_form)
    elsif params[:enrolled_work_program] == "yes"
      new_engagement_form_work_program_path(@engagement_form)
    elsif params[:volunteers_nonprofit] == "yes"
      new_engagement_form_volunteer_path(@engagement_form)
    else
      # If none are selected, go to review page
      review_summary_path(@engagement_form.id)
    end
  end
end
```

Now let me run the tests to make sure everything is still working correctly:


Great! All tests are still passing. Let me also run a broader test to make sure I haven't broken anything else:


Perfect! All tests are passing. Let me start the Rails server to test the form population functionality:


Excellent! I've successfully fixed the form population issue. Here's a summary of the changes made:

## Changes Made

### 1. **Updated All Form Views to Use `form_with model:`**
- **Questions form**: Now uses `form_with model: @engagement_form` so checkboxes show existing selections
- **Jobs form**: Now uses `form_with model: @engagement_form` so text areas show existing job details
- **Students form**: Now uses `form_with model: @engagement_form` so text areas show existing student details
- **Work Programs form**: Now uses `form_with model: @engagement_form` so text areas show existing work program details
- **Volunteers form**: Now uses `form_with model: @engagement_form` so text areas show existing volunteer details

### 2. **Updated All Controllers to Handle Nested Parameters**
- **Questions controller**: Now handles both `params[:engagement_form]` and direct `params` for backward compatibility
- **Jobs controller**: Now extracts `job_details` from nested parameters
- **Students controller**: Now extracts `student_details` from nested parameters
- **Work Programs controller**: Now extracts `work_program_details` from nested parameters
- **Volunteers controller**: Now extracts `volunteer_details` from nested parameters

### 3. **Maintained Backward Compatibility**
- All controllers use `params[:engagement_form]&.dig(:field_name) || params[:field_name]` pattern
- This ensures the forms work whether parameters come nested or directly
- Existing functionality is preserved while adding the new form population feature

## Key Benefits

1. **Form Population**: When users click "Edit" from the review page, forms now show their previous answers
2. **Better UX**: Users don't have to re-enter information they've already provided
3. **Consistent Behavior**: All forms now behave the same way with proper data binding
4. **Backward Compatibility**: Existing functionality continues to work as expected

## How It Works

1. **Form Binding**: Using `form_with model: @engagement_form` tells Rails to bind the form to the existing object
2. **Automatic Population**: Rails automatically populates form fields with the object's current values
3. **Nested Parameters**: When the form is submitted, parameters are nested under `engagement_form`
4. **Controller Handling**: Controllers extract the values from the nested parameters and update the object

## Testing Results

- ✅ All 48 tests passing
- ✅ No breaking changes to existing functionality
- ✅ Forms now properly populated with existing data
- ✅ Backward compatibility maintained

The Rails server is now running and you can test the improved functionality at `http://localhost:3000`. When you go through the form flow and then click "Edit" from the review page, you'll see that all the forms are now populated with your previous answers, making it much easier to review and modify your responses.

---

**User**

Great. One last bug - if I click Edit to go back and update my "Basic Information" in the EngagementFormsController, it takes me to the "new" view where none of my information is being saved. Can you extract the form into a partial and create a "show" view that shares the form, so that I may see my prepopulated "Basic Information" and edit it as well?

---

**Cursor**

You're absolutely right! The issue is that the "Edit" link in the review page goes to `new_engagement_form_path` which creates a new form, rather than editing the existing one. Let me fix this by creating a proper edit flow for the basic information.

First, let me check the current engagement forms controller and routes:


Now let me check the current new view to see the form structure:


Perfect! Now I need to:

1. Add `edit` and `update` actions to the controller
2. Update the routes to include `edit` and `update`
3. Create a form partial that can be shared between `new` and `edit` views
4. Create an `edit` view
5. Update the review page to link to the edit action instead of new

Let me start by updating the routes:


```ruby
Rails.application.routes.draw do
  # Community Engagement Form flow
  resources :engagement_forms, only: [:new, :create, :show, :edit, :update] do
    member do
      get :pdf
    end
    
    # Nested resources that require engagement_form_id
    resources :questions, only: [:new, :create]
    resources :jobs, only: [:new, :create]
    resources :students, only: [:new, :create]
    resources :work_programs, only: [:new, :create]
    resources :volunteers, only: [:new, :create]
  end
  
  # Summary pages
  get "summary/:engagement_form_id", to: "summary#show", as: :summary
  get "summary/:engagement_form_id/review", to: "summary#review", as: :review_summary
  post "summary/:engagement_form_id/submit", to: "summary#submit", as: :submit_summary
  
  # Root route
  root "engagement_forms#new"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
```

Now let me update the controller to add the edit and update actions:


```ruby
class EngagementFormsController < ApplicationController
  def new
    @engagement_form = EngagementForm.new
  end

  def create
    @engagement_form = EngagementForm.new(engagement_form_params)
    
    if @engagement_form.save
      redirect_to new_engagement_form_question_path(@engagement_form)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @engagement_form = EngagementForm.find(params[:id])

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "community_engagement_#{@engagement_form.id}",
               template: "engagement_forms/show",
               layout: "pdf",
               disposition: "attachment"
      end
    end
  end

  def edit
    @engagement_form = EngagementForm.find(params[:id])
  end

  def update
    @engagement_form = EngagementForm.find(params[:id])
    
    if @engagement_form.update(engagement_form_params)
      redirect_to review_summary_path(@engagement_form), notice: 'Basic information updated successfully!'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def engagement_form_params
    params.require(:engagement_form).permit(:user_name, :email, :organization)
  end
end
```

Now let me create a form partial that can be shared between the new and edit views:


```ruby
<%= form_with model: @engagement_form, local: true, class: "usa-form" do |form| %>
  <% if @engagement_form.errors.any? %>
    <div class="usa-alert usa-alert--error" role="alert">
      <div class="usa-alert__body">
        <h3 class="usa-alert__heading">Please correct the following errors:</h3>
        <ul class="usa-alert__text">
          <% @engagement_form.errors.full_messages.each do |message| %>
            <li><%= message %></li>
          <% end %>
        </ul>
      </div>
    </div>
  <% end %>
  
  <fieldset class="usa-fieldset">
    <legend class="usa-legend">Basic Information</legend>
    
    <div class="usa-form-group">
      <%= form.label :user_name, "Full Name", class: "usa-label" %>
      <%= form.text_field :user_name, class: "usa-input", required: true %>
    </div>
    
    <div class="usa-form-group">
      <%= form.label :email, "Email Address", class: "usa-label" %>
      <%= form.email_field :email, class: "usa-input", required: true %>
    </div>
    
    <div class="usa-form-group">
      <%= form.label :organization, "Organization", class: "usa-label" %>
      <%= form.text_field :organization, class: "usa-input", required: true %>
    </div>
  </fieldset>
  
  <div class="usa-form-group">
    <% if @engagement_form.persisted? %>
      <%= form.submit "Update Information", class: "usa-button" %>
      <%= link_to "Cancel", review_summary_path(@engagement_form), class: "usa-button usa-button--outline" %>
    <% else %>
      <%= form.submit "Continue to Questions", class: "usa-button" %>
    <% end %>
  </div>
<% end %>
```

Now let me update the new view to use the partial:


```ruby
<div class="grid-row">
  <div class="grid-col-12">
    <h1 class="usa-prose">Community Engagement Requirements</h1>
    <p class="usa-intro">
      Please complete this form to document your community engagement activities and meet the required standards.
    </p>
    
    <%= render 'form' %>
  </div>
</div>
```

Now let me create the edit view:


```ruby
<div class="grid-row">
  <div class="grid-col-12">
    <h1 class="usa-prose">Edit Basic Information</h1>
    <p class="usa-intro">
      Please review and update your basic information below.
    </p>
    
    <%= render 'form' %>
  </div>
</div>
```

Now I need to update the review page to link to the edit action instead of the new action:


```ruby
<div class="grid-row">
  <div class="grid-col-12">
    <h1 class="usa-prose">Review Your Community Engagement Form</h1>
    
    <div class="usa-alert usa-alert--info" role="alert">
      <div class="usa-alert__body">
        <h3 class="usa-alert__heading">Please Review Your Information</h3>
        <p class="usa-alert__text">
          Please review all your responses below. You can edit any section by clicking the "Edit" link next to it. 
          Once you're satisfied with your answers, click "Submit Form" to complete the process.
        </p>
      </div>
    </div>
    
    <div class="usa-summary-box">
      <div class="usa-summary-box__body">
        <h3 class="usa-summary-box__heading">
          Basic Information
          <%= link_to "Edit", edit_engagement_form_path(@engagement_form), class: "usa-button usa-button--small usa-button--outline", style: "float: right;" %>
        </h3>
        <div class="usa-summary-box__text">
          <p><strong>Name:</strong> <%= @engagement_form.user_name %></p>
          <p><strong>Email:</strong> <%= @engagement_form.email %></p>
          <p><strong>Organization:</strong> <%= @engagement_form.organization %></p>
        </div>
      </div>
    </div>
    
    <div class="usa-summary-box">
      <div class="usa-summary-box__body">
        <h3 class="usa-summary-box__heading">
          Engagement Activities
          <%= link_to "Edit", new_engagement_form_question_path(@engagement_form), class: "usa-button usa-button--small usa-button--outline", style: "float: right;" %>
        </h3>
        <div class="usa-summary-box__text">
          <ul class="usa-list">
            <li><%= @engagement_form.has_job? ? "✅ I have a job" : "❌ I don't have a job" %></li>
            <li><%= @engagement_form.is_student? ? "✅ I am a student" : "❌ I am not a student" %></li>
            <li><%= @engagement_form.enrolled_work_program? ? "✅ I am enrolled in a work program" : "❌ I am not enrolled in a work program" %></li>
            <li><%= @engagement_form.volunteers_nonprofit? ? "✅ I volunteer with a nonprofit organization" : "❌ I don't volunteer with a nonprofit organization" %></li>
          </ul>
        </div>
      </div>
    </div>
    
    <% if @engagement_form.has_job? %>
      <div class="usa-summary-box">
        <div class="usa-summary-box__body">
          <h3 class="usa-summary-box__heading">
            Employment Details
            <%= link_to "Edit", new_engagement_form_job_path(@engagement_form), class: "usa-button usa-button--small usa-button--outline", style: "float: right;" %>
          </h3>
          <div class="usa-summary-box__text">
            <p><%= @engagement_form.job_details %></p>
          </div>
        </div>
      </div>
    <% end %>
    
    <% if @engagement_form.is_student? %>
      <div class="usa-summary-box">
        <div class="usa-summary-box__body">
          <h3 class="usa-summary-box__heading">
            Student Details
            <%= link_to "Edit", new_engagement_form_student_path(@engagement_form), class: "usa-button usa-button--small usa-button--outline", style: "float: right;" %>
          </h3>
          <div class="usa-summary-box__text">
            <p><%= @engagement_form.student_details %></p>
          </div>
        </div>
      </div>
    <% end %>
    
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
    
    <% if @engagement_form.volunteers_nonprofit? %>
      <div class="usa-summary-box">
        <div class="usa-summary-box__body">
          <h3 class="usa-summary-box__heading">
            Volunteer Details
            <%= link_to "Edit", new_engagement_form_volunteer_path(@engagement_form), class: "usa-button usa-button--small usa-button--outline", style: "float: right;" %>
          </h3>
          <div class="usa-summary-box__text">
            <p><%= @engagement_form.volunteer_details %></p>
          </div>
        </div>
      </div>
    <% end %>
    
    <% if !@engagement_form.has_job? && !@engagement_form.is_student? && !@engagement_form.enrolled_work_program? && !@engagement_form.volunteers_nonprofit? %>
      <div class="usa-alert usa-alert--warning" role="alert">
        <div class="usa-alert__body">
          <h3 class="usa-alert__heading">No Engagement Activities Selected</h3>
          <p class="usa-alert__text">You indicated that you do not participate in any of the qualifying engagement activities. Please review the Community Engagement Requirements to ensure you meet the necessary criteria.</p>
        </div>
      </div>
    <% end %>
    
    <div class="usa-form-group">
      <%= form_with url: submit_summary_path(@engagement_form), method: :post, local: true do |form| %>
        <%= form.submit "Submit Form", class: "usa-button" %>
      <% end %>
      <%= link_to "Back to Questions", new_engagement_form_question_path(@engagement_form), class: "usa-button usa-button--outline" %>
    </div>
  </div>
</div>
```

Now let me add tests for the new edit and update functionality:


```ruby
require 'rails_helper'

RSpec.describe "EngagementForms", type: :request do
  let(:engagement_form) { EngagementForm.create!(user_name: "Test User", email: "test@example.com", organization: "Test Org") }

  describe "GET /new" do
    it "returns http success" do
      get "/engagement_forms/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /create" do
    it "creates a new engagement form and redirects to questions" do
      post "/engagement_forms", params: { engagement_form: { user_name: "John Doe", email: "john@example.com", organization: "Test Org" } }
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
      expect(response.body).to include(engagement_form.organization)
    end
  end

  describe "PATCH /update" do
    it "updates the engagement form and redirects to review" do
      patch "/engagement_forms/#{engagement_form.id}", params: { engagement_form: { user_name: "Updated Name", email: "updated@example.com", organization: "Updated Org" } }
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(review_summary_path(engagement_form))
      
      engagement_form.reload
      expect(engagement_form.user_name).to eq("Updated Name")
      expect(engagement_form.email).to eq("updated@example.com")
      expect(engagement_form.organization).to eq("Updated Org")
    end

    it "renders edit view with errors if validation fails" do
      patch "/engagement_forms/#{engagement_form.id}", params: { engagement_form: { user_name: "", email: "invalid-email", organization: "" } }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("Edit Basic Information")
    end
  end
end
```

Now let me run the tests to make sure everything is working correctly:


Great! All tests are passing. Let me also run a broader test to make sure I haven't broken anything else:


Perfect! All tests are passing. Let me start the Rails server to test the new edit functionality:


Excellent! I've successfully fixed the basic information editing issue. Here's a summary of the changes made:

## Changes Made

### 1. **Updated Routes**
- **Added edit and update actions**: Updated `resources :engagement_forms` to include `:edit, :update`
- **Proper RESTful routing**: Now supports both creating new forms and editing existing ones

### 2. **Enhanced Controller**
- **`edit` action**: Loads existing engagement form for editing
- **`update` action**: Updates the form and redirects back to review page
- **Proper error handling**: Renders edit view with errors if validation fails
- **Success feedback**: Shows notice message when update is successful

### 3. **Created Shared Form Partial**
- **`_form.html.erb`**: Reusable form partial for both new and edit views
- **Smart button logic**: Shows "Continue to Questions" for new forms, "Update Information" for editing
- **Cancel button**: Provides cancel option when editing that returns to review page
- **Error display**: Shows validation errors consistently

### 4. **Updated Views**
- **`new.html.erb`**: Now uses the shared form partial
- **`edit.html.erb`**: New view for editing basic information
- **Consistent styling**: Both views maintain the same USWDS styling

### 5. **Fixed Review Page**
- **Updated edit link**: Now points to `edit_engagement_form_path(@engagement_form)` instead of `new_engagement_form_path`
- **Proper navigation**: Users can now edit their basic information and return to review

### 6. **Enhanced Tests**
- **Comprehensive test coverage**: Added tests for edit and update functionality
- **Data validation**: Tests verify that existing data is displayed in edit form
- **Update verification**: Tests confirm that data is properly updated
- **Error handling**: Tests verify validation errors are displayed correctly

## Key Benefits

1. **Proper Form Population**: When users click "Edit" for basic information, the form is now populated with their existing data
2. **Consistent UX**: All edit functionality now works the same way across the application
3. **DRY Code**: Shared form partial eliminates code duplication
4. **Proper Navigation**: Users can edit and return to the review page seamlessly
5. **Error Handling**: Validation errors are properly displayed and handled

## How It Works

1. **Edit Link**: Review page now links to `/engagement_forms/:id/edit`
2. **Form Population**: The edit action loads the existing `@engagement_form` object
3. **Shared Form**: The form partial automatically populates fields with existing data
4. **Update Process**: When submitted, the update action saves changes and redirects to review
5. **Navigation**: Users can cancel and return to review, or submit and continue

## Testing Results

- ✅ All 51 tests passing
- ✅ No breaking changes to existing functionality
- ✅ Basic information editing now works correctly
- ✅ Form population works as expected
- ✅ Proper error handling and validation

The Rails server is now running and you can test the complete edit functionality at `http://localhost:3000`. When you go through the form flow and click "Edit" for basic information from the review page, you'll now see your existing data populated in the form, and you can make changes and save them properly.

