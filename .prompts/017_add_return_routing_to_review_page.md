# Improve navigation to review page
_Exported on 8/30/2025 at 16:50:56 PDT from Cursor (1.5.7)_

---

**User**

I would like you to improve the navigation between the "review" page and the other pages. Currently, the review page links back to previous pages, but each page then takes you through the remaining pages in the flow in order to get back to the review page. I'd like it to go directly back to the review page after saving each other page.

Can you update the jobs, student, work programs, and volunteer pages such that if the user came from a link on the review page, it takes them immediately back to the review page after saving?

---

**Cursor**

I'll help you improve the navigation flow so that when users come from the review page, they return directly to it after saving. Let me first examine the current structure to understand how the navigation works.


Now let me check the other pages to understand the current navigation pattern:


Now let me check the review page to understand how it links to these pages:


Now let me check the controllers to understand how the redirect logic works:


Now let me check the current controllers to see how they handle redirects:


Now I understand the current flow. The issue is that when users click "Edit" from the review page, they go to the respective pages, but after saving, they go through the normal flow instead of returning directly to the review page. I need to modify the controllers to detect when they came from the review page and redirect back there.

Let me check if there's a way to detect the referrer or if we need to add a parameter:


Perfect! I can see that the `engagement_forms_controller.rb` already has a good example of how to handle this. In the `update` method, it redirects back to the review page after updating. I need to implement a similar pattern for the other controllers.

The best approach is to add a `from_review` parameter to the edit links in the review page, and then check for this parameter in the controllers to determine whether to redirect back to the review page.

Let me start by updating the review page to include the `from_review` parameter in the edit links:


```ruby
          <%= link_to "Edit", new_engagement_form_job_path(@engagement_form), class: "usa-button usa-button--small usa-button--outline", style: "float: right;" %>

->

          <%= link_to "Edit", new_engagement_form_job_path(@engagement_form, from_review: true), class: "usa-button usa-button--small usa-button--outline", style: "float: right;" %>
```

```ruby
            <%= link_to "Edit", new_engagement_form_student_path(@engagement_form), class: "usa-button usa-button--small usa-button--outline", style: "float: right;" %>

->

            <%= link_to "Edit", new_engagement_form_student_path(@engagement_form, from_review: true), class: "usa-button usa-button--small usa-button--outline", style: "float: right;" %>
```

```ruby
            <%= link_to "Edit", new_engagement_form_work_program_path(@engagement_form), class: "usa-button usa-button--small usa-button--outline", style: "float: right;" %>

->

            <%= link_to "Edit", new_engagement_form_work_program_path(@engagement_form, from_review: true), class: "usa-button usa-button--small usa-button--outline", style: "float: right;" %>
```

```ruby
            <%= link_to "Edit", new_engagement_form_volunteer_path(@engagement_form), class: "usa-button usa-button--small usa-button--outline", style: "float: right;" %>

->

            <%= link_to "Edit", new_engagement_form_volunteer_path(@engagement_form, from_review: true), class: "usa-button usa-button--small usa-button--outline", style: "float: right;" %>
```

Now I need to update the controllers to check for the `from_review` parameter and redirect back to the review page when it's present. Let me start with the jobs controller:


```ruby
  def create
    @engagement_form = EngagementForm.find(params[:engagement_form_id])
    
    # Use the new next_path method
    redirect_to next_path(@engagement_form)
  end

->

  def create
    @engagement_form = EngagementForm.find(params[:engagement_form_id])
    
    # Check if user came from review page
    if params[:from_review] == "true"
      redirect_to review_summary_path(@engagement_form)
    else
      # Use the new next_path method
      redirect_to next_path(@engagement_form)
    end
  end
```

Now let me update the students controller:


```ruby
    # Validate with the students_page context
    if @engagement_form.valid?(:students_page)
      @engagement_form.save!
      # Use the new next_path method
      redirect_to next_path(@engagement_form)
    else
      # Re-render the form with validation errors
      render :new, status: :unprocessable_entity
    end

->

    # Validate with the students_page context
    if @engagement_form.valid?(:students_page)
      @engagement_form.save!
      # Check if user came from review page
      if params[:from_review] == "true"
        redirect_to review_summary_path(@engagement_form)
      else
        # Use the new next_path method
        redirect_to next_path(@engagement_form)
      end
    else
      # Re-render the form with validation errors
      render :new, status: :unprocessable_entity
    end
```

Now let me update the work programs controller:


```ruby
    # Validate with the work_programs_page context
    if @engagement_form.valid?(:work_programs_page)
      @engagement_form.save!
      # Use the new next_path method
      redirect_to next_path(@engagement_form)
    else
      # Re-render the form with validation errors
      render :new, status: :unprocessable_entity
    end

->

    # Validate with the work_programs_page context
    if @engagement_form.valid?(:work_programs_page)
      @engagement_form.save!
      # Check if user came from review page
      if params[:from_review] == "true"
        redirect_to review_summary_path(@engagement_form)
      else
        # Use the new next_path method
        redirect_to next_path(@engagement_form)
      end
    else
      # Re-render the form with validation errors
      render :new, status: :unprocessable_entity
    end
```

Now let me update the volunteers controller:


```ruby
  def create
    @engagement_form = EngagementForm.find(params[:engagement_form_id])
    
    # Go to review page since this is the last step
    redirect_to review_summary_path(@engagement_form.id)
  end

->

  def create
    @engagement_form = EngagementForm.find(params[:engagement_form_id])
    
    # Check if user came from review page
    if params[:from_review] == "true"
      redirect_to review_summary_path(@engagement_form)
    else
      # Go to review page since this is the last step
      redirect_to review_summary_path(@engagement_form.id)
    end
  end
```

Now I need to update the form views to pass the `from_review` parameter when the form is submitted. Let me start with the jobs page:


```ruby
    <div class="usa-form-group">
      <%= form_with url: engagement_form_jobs_path(@engagement_form), method: :post, local: true do |form| %>
        <%= form.submit "Continue", class: "usa-button" %>
        <%= link_to "Back", new_engagement_form_question_path(@engagement_form), class: "usa-button usa-button--outline" %>
      <% end %>
    </div>

->

    <div class="usa-form-group">
      <%= form_with url: engagement_form_jobs_path(@engagement_form), method: :post, local: true do |form| %>
        <%= hidden_field_tag :from_review, params[:from_review] if params[:from_review] %>
        <%= form.submit "Continue", class: "usa-button" %>
        <%= link_to "Back", new_engagement_form_question_path(@engagement_form), class: "usa-button usa-button--outline" %>
      <% end %>
    </div>
```

Now let me update the students page:


```ruby
    <%= form_with model: @engagement_form, url: engagement_form_students_path(@engagement_form), method: :post, local: true, class: "usa-form", builder: UswdsFormBuilder do |form| %>

->

    <%= form_with model: @engagement_form, url: engagement_form_students_path(@engagement_form), method: :post, local: true, class: "usa-form", builder: UswdsFormBuilder do |form| %>
      <%= hidden_field_tag :from_review, params[:from_review] if params[:from_review] %>
```

Now let me update the work programs page:


```ruby
    <%= form_with model: @engagement_form, url: engagement_form_work_programs_path(@engagement_form), method: :post, local: true, class: "usa-form", builder: UswdsFormBuilder do |form| %>

->

    <%= form_with model: @engagement_form, url: engagement_form_work_programs_path(@engagement_form), method: :post, local: true, class: "usa-form", builder: UswdsFormBuilder do |form| %>
      <%= hidden_field_tag :from_review, params[:from_review] if params[:from_review] %>
```

Now let me update the volunteers page:


```ruby
    <div class="usa-form-group">
      <%= form_with url: engagement_form_volunteers_path(@engagement_form), method: :post, local: true do |form| %>
        <%= form.submit "Continue", class: "usa-button" %>
        <%= link_to "Back", new_engagement_form_question_path(@engagement_form), class: "usa-button usa-button--outline" %>
      <% end %>
    </div>

->

    <div class="usa-form-group">
      <%= form_with url: engagement_form_volunteers_path(@engagement_form), method: :post, local: true do |form| %>
        <%= hidden_field_tag :from_review, params[:from_review] if params[:from_review] %>
        <%= form.submit "Continue", class: "usa-button" %>
        <%= link_to "Back", new_engagement_form_question_path(@engagement_form), class: "usa-button usa-button--outline" %>
      <% end %>
    </div>
```

Now let me check if there are any Agents.md files that need to be updated:


The Agents.md file looks comprehensive and up-to-date. The changes I made are related to navigation flow improvements, which are already covered in the existing documentation about the dynamic routing system and controller structure.

Let me run a quick test to make sure the changes work correctly:


Perfect! The routes are correctly set up. Now let me run a quick test to make sure the application starts without errors:


Excellent! The application loads successfully. Let me also run the tests to make sure I haven't broken anything:


Perfect! All tests are passing. The navigation improvements have been successfully implemented. Let me summarize what I've accomplished:

## Summary

I've successfully improved the navigation flow between the review page and the other pages. Here's what was implemented:

### Changes Made:

1. **Updated Review Page Links**: Modified all "Edit" links in `app/views/summary/review.html.erb` to include a `from_review: true` parameter when linking to the detail pages.

2. **Enhanced Controllers**: Updated all four controllers (`JobsController`, `StudentsController`, `WorkProgramsController`, and `VolunteersController`) to check for the `from_review` parameter and redirect back to the review page when present.

3. **Updated Form Views**: Added hidden fields to all form views to preserve the `from_review` parameter when forms are submitted.

### How It Works:

- When users click "Edit" from the review page, they go to the respective detail page with `from_review: true` parameter
- The detail page forms include a hidden field to preserve this parameter
- When the form is submitted, the controller checks for the `from_review` parameter
- If present, it redirects directly back to the review page instead of following the normal flow
- If not present, it follows the existing `next_path` logic

### Benefits:

- **Improved UX**: Users can now edit sections from the review page and return directly to review without going through the entire flow again
- **Maintains Existing Flow**: The normal form progression still works as before for users going through the form for the first time
- **Clean Implementation**: Uses a simple parameter-based approach that's easy to understand and maintain

The implementation is backward compatible and all existing tests continue to pass. Users can now seamlessly edit any section from the review page and return directly to review after saving their changes.

---

**User**

Remove the "Back" buttons.

---

**Cursor**

I'll remove the "Back" buttons from all the detail pages. Let me update each view file:


```ruby
    <div class="usa-form-group">
      <%= form_with url: engagement_form_jobs_path(@engagement_form), method: :post, local: true do |form| %>
        <%= hidden_field_tag :from_review, params[:from_review] if params[:from_review] %>
        <%= form.submit "Continue", class: "usa-button" %>
        <%= link_to "Back", new_engagement_form_question_path(@engagement_form), class: "usa-button usa-button--outline" %>
      <% end %>
    </div>

->

    <div class="usa-form-group">
      <%= form_with url: engagement_form_jobs_path(@engagement_form), method: :post, local: true do |form| %>
        <%= hidden_field_tag :from_review, params[:from_review] if params[:from_review] %>
        <%= form.submit "Continue", class: "usa-button" %>
      <% end %>
    </div>
```

```ruby
      <div class="usa-form-group">
        <%= form.submit "Continue", class: "usa-button" %>
        <%= link_to "Back", new_engagement_form_question_path(@engagement_form), class: "usa-button usa-button--outline" %>
      </div>

->

      <div class="usa-form-group">
        <%= form.submit "Continue", class: "usa-button" %>
      </div>
```

```ruby
      <div class="usa-form-group">
        <%= form.submit "Continue", class: "usa-button" %>
        <%= link_to "Back", new_engagement_form_question_path(@engagement_form), class: "usa-button usa-button--outline" %>
      </div>

->

      <div class="usa-form-group">
        <%= form.submit "Continue", class: "usa-button" %>
      </div>
```

```ruby
    <div class="usa-form-group">
      <%= form_with url: engagement_form_volunteers_path(@engagement_form), method: :post, local: true do |form| %>
        <%= hidden_field_tag :from_review, params[:from_review] if params[:from_review] %>
        <%= form.submit "Continue", class: "usa-button" %>
        <%= link_to "Back", new_engagement_form_question_path(@engagement_form), class: "usa-button usa-button--outline" %>
      <% end %>
    </div>

->

    <div class="usa-form-group">
      <%= form_with url: engagement_form_volunteers_path(@engagement_form), method: :post, local: true do |form| %>
        <%= hidden_field_tag :from_review, params[:from_review] if params[:from_review] %>
        <%= form.submit "Continue", class: "usa-button" %>
      <% end %>
    </div>
```

Perfect! I've removed all the "Back" buttons from the jobs, students, work programs, and volunteers pages. Now users will only see the "Continue" button on each page, which provides a cleaner and more streamlined user experience. The navigation flow is now more linear and focused on moving forward through the form.

---

**User**

The "Engagement Activities" edit button on review also needs a "from_review" parameter and routing logic.

---

**Cursor**

You're absolutely right! The "Engagement Activities" edit button on the review page also needs the `from_review` parameter and corresponding routing logic. Let me fix that.

First, let me update the review page to add the `from_review` parameter to the Engagement Activities edit link:


```ruby
          <%= link_to "Edit", new_engagement_form_question_path(@engagement_form), class: "usa-button usa-button--small usa-button--outline", style: "float: right;" %>

->

          <%= link_to "Edit", new_engagement_form_question_path(@engagement_form, from_review: true), class: "usa-button usa-button--small usa-button--outline", style: "float: right;" %>
```

Now I need to update the questions controller to handle the `from_review` parameter:


Now I'll update the questions controller to check for the `from_review` parameter:


```ruby
    # Use the new next_path method
    redirect_to next_path(@engagement_form)

->

    # Check if user came from review page
    if params[:from_review] == "true"
      redirect_to review_summary_path(@engagement_form)
    else
      # Use the new next_path method
      redirect_to next_path(@engagement_form)
    end
```

Now I need to check the questions view to see if it needs the hidden field for the `from_review` parameter:


I need to add the hidden field for the `from_review` parameter to the questions form:


```ruby
    <%= form_with model: @engagement_form, url: engagement_form_questions_path(@engagement_form), method: :post, local: true, class: "usa-form", builder: UswdsFormBuilder do |form| %>

->

    <%= form_with model: @engagement_form, url: engagement_form_questions_path(@engagement_form), method: :post, local: true, class: "usa-form", builder: UswdsFormBuilder do |form| %>
      <%= hidden_field_tag :from_review, params[:from_review] if params[:from_review] %>
```

I should also remove the "Back" button from the questions page to be consistent with the other pages:


```ruby
      <div class="usa-form-group">
        <%= form.submit "Continue", class: "usa-button" %>
        <%= link_to "Back", new_engagement_form_path, class: "usa-button usa-button--outline" %>
      </div>

->

      <div class="usa-form-group">
        <%= form.submit "Continue", class: "usa-button" %>
      </div>
```

Now let me run a quick test to make sure everything still works:


Perfect! I've successfully updated the "Engagement Activities" edit functionality to include the `from_review` parameter and routing logic. Here's what was implemented:

## Changes Made:

1. **Updated Review Page**: Added `from_review: true` parameter to the "Engagement Activities" edit link in the review page.

2. **Enhanced Questions Controller**: Updated the `QuestionsController` to check for the `from_review` parameter and redirect back to the review page when present.

3. **Updated Questions Form**: Added a hidden field to preserve the `from_review` parameter when the form is submitted.

4. **Removed Back Button**: Removed the "Back" button from the questions page to maintain consistency with the other detail pages.

## How It Works:

- When users click "Edit" on the "Engagement Activities" section from the review page, they go to the questions page with `from_review: true` parameter
- The questions form includes a hidden field to preserve this parameter
- When the form is submitted, the controller checks for the `from_review` parameter
- If present, it redirects directly back to the review page instead of following the normal flow
- If not present, it follows the existing `next_path` logic

Now all edit links from the review page (Basic Information, Engagement Activities, Employment Details, Student Details, Work Program Details, and Volunteer Hours) will properly return users to the review page after saving their changes.

---

**User**

Fix this error when I submit the form: undefined method 'work_program_details' for an instance of EngagementForm

---

**Cursor**

I need to investigate this error. It seems like there's a reference to `work_program_details` somewhere in the code that doesn't exist. Let me search for where this method is being called.


I found the issue! There are still references to `work_program_details` in the view files. Let me check the current work programs controller to see what fields it's actually using:


Good! The work programs controller is correctly using `work_program_name` and `hours_attended` fields. Now let me check the EngagementForm model to see what fields are actually available:


Perfect! The model shows that the correct fields are `work_program_name` and `hours_attended`. Now I need to fix the view files that are still referencing the old `work_program_details` field. Let me update them:


I found the issue! The engagement forms show view is still referencing `work_program_details`. Let me fix this:


```ruby
    <% if @engagement_form.work_program_details.present? %>
      <div class="usa-summary-box">
        <div class="usa-summary-box__body">
          <h3 class="usa-summary-box__heading">Work Program Details</h3>
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
          <h3 class="usa-summary-box__heading">Work Program Details</h3>
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

Now let me check the summary show view:


I found another reference to `work_program_details` in the summary show view. Let me fix this:


```ruby
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

->

    <% if @engagement_form.enrolled_work_program? %>
      <div class="usa-summary-box">
        <div class="usa-summary-box__body">
          <h3 class="usa-summary-box__heading">✅ Work Program</h3>
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

Now let me run a test to make sure the application loads without errors:


Great! Let me also run the tests to make sure everything is working correctly:


Perfect! All tests are passing. I've successfully fixed the `undefined method 'work_program_details'` error by updating the view files to use the correct field names.

## Summary of the Fix:

The error was caused by outdated references to the `work_program_details` field in the view files. This field was removed in a previous migration and replaced with specific fields: `work_program_name` and `hours_attended`.

### Changes Made:

1. **Updated `app/views/engagement_forms/show.html.erb`**: 
   - Changed the condition from `@engagement_form.work_program_details.present?` to `@engagement_form.enrolled_work_program?`
   - Replaced the single field display with structured display of `work_program_name` and `hours_attended`

2. **Updated `app/views/summary/show.html.erb`**:
   - Replaced the reference to `@engagement_form.work_program_details` with structured display of the correct fields

### Current Work Program Fields:
- `work_program_name` (string) - The name of the work program
- `hours_attended` (decimal) - The number of hours attended in the work program

The application now correctly displays work program information using the proper field names, and all tests are passing. The form should now submit successfully without the undefined method error.

