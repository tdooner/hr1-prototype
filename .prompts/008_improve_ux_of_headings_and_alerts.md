# Fix duplicate success message on jobs page
_Exported on 8/30/2025 at 14:07:23 PDT from Cursor (1.5.7)_

---

**User**

Let's make a couple changes regarding the use of "usa-alert" components.

First, after adding a paycheck on the "jobs" page, I get the success message "Paycheck added successfully!" twice. Fix that so it only displays once.


---

**Cursor**

I'll help you fix the duplicate success message issue. Let me first examine the current jobs page and related files to understand how the success message is being displayed.


Now let me check the jobs controller to see how the success message is being set:


Let me also check the job paychecks controller since that's likely where the paycheck is being added:


Now let me check if there's a layout file or application controller that might be adding another success message:


Let me check the application layout to see if there's a flash message display that might be duplicating the notice:


I found the issue! The success message is being displayed twice because:

1. The application layout (`app/views/layouts/application.html.erb`) displays the `notice` flash message at lines 47-53
2. The jobs page (`app/views/jobs/new.html.erb`) also displays the `notice` flash message at lines 9-15

This creates a duplicate display of the same success message. I need to remove the duplicate from the jobs page since the application layout already handles displaying flash messages.


```ruby
    <p class="usa-intro">
      Please add your paychecks to help verify that you meet the Community Engagement Requirements.
    </p>

    <% if notice %>
      <div class="usa-alert usa-alert--success" role="alert">
        <div class="usa-alert__body">
          <p class="usa-alert__text"><%= notice %></p>
        </div>
      </div>
    <% end %>

->

    <p class="usa-intro">
      Please add your paychecks to help verify that you meet the Community Engagement Requirements.
    </p>
```

Perfect! I've removed the duplicate success message display from the jobs page. The success message "Paycheck added successfully!" will now only appear once, displayed by the application layout which handles all flash messages centrally.

The fix removes the redundant `usa-alert` component from the jobs page since the application layout already provides a consistent way to display flash messages across all pages.

---

**User**

The volunteers page has the same problem.

---

**Cursor**

I'll check the volunteers page to fix the same duplicate success message issue.


Perfect! I can see the same issue on the volunteers page. There's a duplicate `usa-alert` component at lines 9-15 that displays the `notice` flash message, which is already handled by the application layout. I'll remove this duplicate.


```ruby
    <p class="usa-intro">
      Please add your volunteer shifts to help verify that you meet the Community Engagement Requirements.
    </p>

    <% if notice %>
      <div class="usa-alert usa-alert--success" role="alert">
        <div class="usa-alert__body">
          <p class="usa-alert__text"><%= notice %></p>
        </div>
      </div>
    <% end %>

->

    <p class="usa-intro">
      Please add your volunteer shifts to help verify that you meet the Community Engagement Requirements.
    </p>
```

Great! I've fixed the same duplicate success message issue on the volunteers page. Now both the jobs and volunteers pages will only display success messages once, using the centralized flash message handling in the application layout.

---

**User**

Great. That solves that problem. One other change: On the summary page there is an informational alert used to prompt the user to "Please review your information". Please take that text out of an alert so it's less visually prominent.

---

**Cursor**

I'll help you make that change on the summary page. Let me first find and examine the summary page to see the current informational alert.


Perfect! I can see the informational alert at lines 5-12 that contains the "Please Review Your Information" text. I'll convert this from a `usa-alert` component to regular text to make it less visually prominent.


```ruby
    <div class="usa-alert usa-alert--info" role="alert">
      <div class="usa-alert__body">
        <h3 class="usa-alert__heading">Please Review Your Information</h3>
        <p class="usa-alert__text">
          Please review all your responses below. You can edit any section by clicking the "Edit" link next to it. 
          Once you're satisfied with your answers, click "Submit Form" to complete the process.
        </p>
      </div>
    </div>

->

    <p class="usa-intro">
      Please review all your responses below. You can edit any section by clicking the "Edit" link next to it. 
      Once you're satisfied with your answers, click "Submit Form" to complete the process.
    </p>
```

Perfect! I've converted the informational alert to a simple paragraph with the `usa-intro` class, which will make the "Please review your information" text much less visually prominent while still maintaining good readability and styling consistency with the US Web Design System.

---

**User**

Please use a standard <p> instead of the usa-intro styling.

---

**Cursor**

```ruby
    <p class="usa-intro">
      Please review all your responses below. You can edit any section by clicking the "Edit" link next to it. 
      Once you're satisfied with your answers, click "Submit Form" to complete the process.
    </p>

->

    <p>
      Please review all your responses below. You can edit any section by clicking the "Edit" link next to it. 
      Once you're satisfied with your answers, click "Submit Form" to complete the process.
    </p>
```

Done! I've changed the text to use a standard `<p>` tag without any special styling, making it even less visually prominent.

---

**User**

The <h1> on the summary page is too small because it has the usa-prose class applied directly onto it. Move the usa-prose class onto a containing element instead.

---

**Cursor**

```ruby
<div class="grid-row">
  <div class="grid-col-12">
    <h1 class="usa-prose">Review Your Community Engagement Form</h1>

->

<div class="grid-row">
  <div class="grid-col-12 usa-prose">
    <h1>Review Your Community Engagement Form</h1>
```

Perfect! I've moved the `usa-prose` class from the `<h1>` element to its containing `<div>`. This will allow the heading to display at its proper size while still maintaining the prose styling for the content within that container.

---

**User**

Apply this fix to the <h1> styling across all pages

---

**Cursor**

I'll search for all pages with `<h1 class="usa-prose">` and apply the same fix by moving the `usa-prose` class to the containing element.


Now I'll fix each of the actual view files (not the prompt files). Let me start with the jobs page:


```ruby
<div class="grid-row">
  <div class="grid-col-12">
    <h1 class="usa-prose">Employment Details</h1>

->

<div class="grid-row">
  <div class="grid-col-12 usa-prose">
    <h1>Employment Details</h1>
```

```ruby
<div class="grid-row">
  <div class="grid-col-12">
    <h1 class="usa-prose">Student Details</h1>

->

<div class="grid-row">
  <div class="grid-col-12 usa-prose">
    <h1>Student Details</h1>
```

```ruby
<div class="grid-row">
  <div class="grid-col-12">
    <h1 class="usa-prose">Community Engagement Requirements</h1>

->

<div class="grid-row">
  <div class="grid-col-12 usa-prose">
    <h1>Community Engagement Requirements</h1>
```

```ruby
<div class="grid-row">
  <div class="grid-col-12">
    <h1 class="usa-prose">Community Engagement Requirements</h1>

->

<div class="grid-row">
  <div class="grid-col-12 usa-prose">
    <h1>Community Engagement Requirements</h1>
```

```ruby
<div class="grid-row">
  <div class="grid-col-12">
    <h1 class="usa-prose">Edit Basic Information</h1>

->

<div class="grid-row">
  <div class="grid-col-12 usa-prose">
    <h1>Edit Basic Information</h1>
```

```ruby
<div class="grid-row">
  <div class="grid-col-12">
    <h1 class="usa-prose">Community Engagement Form Submitted</h1>

->

<div class="grid-row">
  <div class="grid-col-12 usa-prose">
    <h1>Community Engagement Form Submitted</h1>
```

```ruby
<div class="grid-row">
  <div class="grid-col-12">
    <h1 class="usa-prose">Work Program Details</h1>

->

<div class="grid-row">
  <div class="grid-col-12 usa-prose">
    <h1>Work Program Details</h1>
```

```ruby
<div class="grid-row">
  <div class="grid-col-12">
    <h1 class="usa-prose">Community Engagement Requirements</h1>

->

<div class="grid-row">
  <div class="grid-col-12 usa-prose">
    <h1>Community Engagement Requirements</h1>
```

```ruby
<div class="grid-row">
  <div class="grid-col-12">
    <h1 class="usa-prose">Add Volunteer Hours</h1>

->

<div class="grid-row">
  <div class="grid-col-12 usa-prose">
    <h1>Add Volunteer Hours</h1>
```

```ruby
<div class="grid-row">
  <div class="grid-col-12">
    <h1 class="usa-prose">Add Paycheck</h1>

->

<div class="grid-row">
  <div class="grid-col-12 usa-prose">
    <h1>Add Paycheck</h1>
```

```ruby
<div class="grid-row">
  <div class="grid-col-12">
    <h1 class="usa-prose">Volunteer Hours</h1>

->

<div class="grid-row">
  <div class="grid-col-12 usa-prose">
    <h1>Volunteer Hours</h1>
```

```ruby
<div class="grid-row">
  <div class="grid-col-12">
    <h1 class="usa-prose">Community Engagement Form Summary</h1>

->

<div class="grid-row">
  <div class="grid-col-12 usa-prose">
    <h1>Community Engagement Form Summary</h1>
```

Perfect! I've successfully applied the fix to all pages by moving the `usa-prose` class from the `<h1>` elements to their containing `<div>` elements. This will allow all headings to display at their proper size while maintaining the prose styling for the content within each container.

The changes were applied to:
- Jobs page (`app/views/jobs/new.html.erb`)
- Students page (`app/views/students/new.html.erb`)
- Engagement types page (`app/views/engagement_forms/engagement_types.html.erb`)
- New engagement form page (`app/views/engagement_forms/new.html.erb`)
- Edit engagement form page (`app/views/engagement_forms/edit.html.erb`)
- Show engagement form page (`app/views/engagement_forms/show.html.erb`)
- Work programs page (`app/views/work_programs/new.html.erb`)
- Questions page (`app/views/questions/new.html.erb`)
- Volunteer shifts page (`app/views/volunteer_shifts/new.html.erb`)
- Job paychecks page (`app/views/job_paychecks/new.html.erb`)
- Volunteers page (`app/views/volunteers/new.html.erb`)
- Summary show page (`app/views/summary/show.html.erb`)

All headings will now display at their proper size while maintaining consistent styling throughout the application.

