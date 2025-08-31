# Fix radio button validation error
_Exported on 8/30/2025 at 17:07:48 PDT from Cursor (1.5.7)_

---

**User**

There's a bug on the students page, with the radio button components. If there is a validation error, Rails outputs a <div class="field_with_errors"> around the <input> for the radio button, and that breaks USWDS. Fix it?

---

**Cursor**

I'll help you fix the radio button validation error issue with USWDS. Let me first examine the current students page to understand the problem.


Now let me check the USWDS form builder to understand how radio buttons are currently being rendered:


Now I can see the issue! The problem is that Rails automatically wraps form inputs with validation errors in a `<div class="field_with_errors">` wrapper, but the USWDS form builder is already handling error styling through its own methods. This creates a conflict where the Rails wrapper breaks the USWDS styling.

Let me check if there's a way to disable Rails' automatic field error wrapping:


Let me check the application configuration to see if there's already a setting to disable field_with_errors:


Perfect! I can see that the `field_with_errors` wrapper is not disabled. The solution is to add a configuration setting to disable Rails' automatic field error wrapping since the USWDS form builder is already handling error styling properly.

Let me add the configuration to disable `field_with_errors`:


```ruby
    # Don't generate system test files.
    config.generators.system_tests = nil
  end
end

->

    # Don't generate system test files.
    config.generators.system_tests = nil
    
    # Disable Rails' automatic field_with_errors wrapper since we handle errors with USWDS styling
    config.action_view.field_error_proc = Proc.new { |html_tag, instance| html_tag.html_safe }
  end
end
```

Now let me check the Agents.md file to see if it needs updating:


The Agents.md file looks comprehensive and up-to-date. The fix I implemented (disabling Rails' automatic `field_with_errors` wrapper) is a configuration change that doesn't require updating the documentation since it's a technical implementation detail that's already covered by the existing USWDS form builder documentation.

The fix I implemented resolves the radio button validation error issue by:

1. **Disabling Rails' automatic `field_with_errors` wrapper** in the application configuration
2. **Allowing the USWDS form builder to handle error styling** properly without interference from Rails' default error wrapping

This ensures that when validation errors occur on radio buttons, the USWDS styling will work correctly without being broken by Rails' automatic error wrapper divs.

---

**User**

Make all of the forms "usa-form--large"

---

**Cursor**

I'll update all the forms to use the `usa-form--large` class. Let me search for all the forms in the application and update them.


Now let me find all the actual view files that contain forms:


Let me check each view directory for forms:


Now I'll update all the forms to use the `usa-form--large` class. I'll start with the main forms:


```ruby
<%= form_with model: @engagement_form, local: true, class: "usa-form", builder: UswdsFormBuilder do |form| %>

->

<%= form_with model: @engagement_form, local: true, class: "usa-form usa-form--large", builder: UswdsFormBuilder do |form| %>
```

```ruby
    <%= form_with model: @engagement_form, url: engagement_form_questions_path(@engagement_form), method: :post, local: true, class: "usa-form", builder: UswdsFormBuilder do |form| %>

->

    <%= form_with model: @engagement_form, url: engagement_form_questions_path(@engagement_form), method: :post, local: true, class: "usa-form usa-form--large", builder: UswdsFormBuilder do |form| %>
```

```ruby
    <%= form_with model: @engagement_form, url: engagement_form_students_path(@engagement_form), method: :post, local: true, class: "usa-form", builder: UswdsFormBuilder do |form| %>

->

    <%= form_with model: @engagement_form, url: engagement_form_students_path(@engagement_form), method: :post, local: true, class: "usa-form usa-form--large", builder: UswdsFormBuilder do |form| %>
```

```ruby
    <%= form_with model: @engagement_form, url: engagement_form_work_programs_path(@engagement_form), method: :post, local: true, class: "usa-form", builder: UswdsFormBuilder do |form| %>

->

    <%= form_with model: @engagement_form, url: engagement_form_work_programs_path(@engagement_form), method: :post, local: true, class: "usa-form usa-form--large", builder: UswdsFormBuilder do |form| %>
```

```ruby
    <%= form_with model: [@engagement_form, @job_paycheck], local: true, class: "usa-form", builder: UswdsFormBuilder do |form| %>

->

    <%= form_with model: [@engagement_form, @job_paycheck], local: true, class: "usa-form usa-form--large", builder: UswdsFormBuilder do |form| %>
```

```ruby
    <%= form_with model: [@engagement_form, @volunteer_shift], local: true, class: "usa-form", builder: UswdsFormBuilder do |form| %>

->

    <%= form_with model: [@engagement_form, @volunteer_shift], local: true, class: "usa-form usa-form--large", builder: UswdsFormBuilder do |form| %>
```

Now I need to update the forms in the jobs and volunteers pages that don't use the UswdsFormBuilder:


```ruby
      <%= form_with url: engagement_form_jobs_path(@engagement_form), method: :post, local: true do |form| %>

->

      <%= form_with url: engagement_form_jobs_path(@engagement_form), method: :post, local: true, class: "usa-form usa-form--large" do |form| %>
```

```ruby
      <%= form_with url: engagement_form_volunteers_path(@engagement_form), method: :post, local: true do |form| %>

->

      <%= form_with url: engagement_form_volunteers_path(@engagement_form), method: :post, local: true, class: "usa-form usa-form--large" do |form| %>
```

Perfect! I've successfully updated all the forms in the application to use the `usa-form--large` class. This includes:

1. **Main forms:**
   - Engagement form (`_form.html.erb`)
   - Questions form (`questions/new.html.erb`)
   - Students form (`students/new.html.erb`)
   - Work programs form (`work_programs/new.html.erb`)

2. **Detail forms:**
   - Job paychecks form (`job_paychecks/new.html.erb`)
   - Volunteer shifts form (`volunteer_shifts/new.html.erb`)

3. **Navigation forms:**
   - Jobs continue form (`jobs/new.html.erb`)
   - Volunteers continue form (`volunteers/new.html.erb`)

All forms now use the `usa-form usa-form--large` class combination, which will provide larger, more spacious form styling throughout the application.

