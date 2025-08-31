# Remove tailwind CSS from project
_Exported on 8/30/2025 at 22:46:49 PDT from Cursor (1.5.7)_

---

**User**

Remove all traces of tailwind CSS

---

**Cursor**

I'll help you remove all traces of Tailwind CSS from your Rails application. Let me first examine the current state of your project to identify all Tailwind-related files and configurations.


Now I'll start removing all traces of Tailwind CSS from your Rails application. Based on my analysis, I need to:

1. Remove the Tailwind gem from Gemfile
2. Remove Tailwind-related files and directories
3. Update the Procfile.dev to remove Tailwind watch command
4. Remove Tailwind-related test files
5. Update the application layout to remove Tailwind references

Let me start:


```ruby
# Use Tailwind CSS [https://github.com/rails/tailwindcss-rails]
gem "tailwindcss-rails"

->


```

```plaintext
css: bin/rails tailwindcss:watch

->


```

Now I need to remove all the Tailwind-related test files:


Now let me check if there are any Tailwind classes in the views that need to be removed:


I can see that the application is using USWDS (US Web Design System) classes, not Tailwind classes. The classes like `usa-form-group`, `usa-alert`, etc. are USWDS classes. However, I found some Tailwind classes in the create action views. Let me check the application layout to see if there are any Tailwind references:


Good! The application layout is already using USWDS and doesn't have any Tailwind references. Now let me remove the Tailwind classes from the create action views:


```ruby
<div>
  <h1 class="font-bold text-4xl">Jobs#create</h1>
  <p>Find me in app/views/jobs/create.html.erb</p>
</div>

->

<div>
  <h1>Jobs#create</h1>
  <p>Find me in app/views/jobs/create.html.erb</p>
</div>
```

```ruby
<div>
  <h1 class="font-bold text-4xl">JobPaychecks#create</h1>
  <p>Find me in app/views/job_paychecks/create.html.erb</p>
</div>

->

<div>
  <h1>JobPaychecks#create</h1>
  <p>Find me in app/views/job_paychecks/create.html.erb</p>
</div>
```

```ruby
<div>
  <h1 class="font-bold text-4xl">Questions#create</h1>
  <p>Find me in app/views/questions/create.html.erb</p>
</div>

->

<div>
  <h1>Questions#create</h1>
  <p>Find me in app/views/questions/create.html.erb</p>
</div>
```

```ruby
<div>
  <h1 class="font-bold text-4xl">EngagementForms#create</h1>
  <p>Find me in app/views/engagement_forms/create.html.erb</p>
</div>

->

<div>
  <h1>EngagementForms#create</h1>
  <p>Find me in app/views/engagement_forms/create.html.erb</p>
</div>
```

```ruby
<div>
  <h1 class="font-bold text-4xl">Students#create</h1>
  <p>Find me in app/views/students/create.html.erb</p>
</div>

->

<div>
  <h1>Students#create</h1>
  <p>Find me in app/views/students/create.html.erb</p>
</div>
```

```ruby
<div>
  <h1 class="font-bold text-4xl">Volunteers#create</h1>
  <p>Find me in app/views/volunteers/create.html.erb</p>
</div>

->

<div>
  <h1>Volunteers#create</h1>
  <p>Find me in app/views/volunteers/create.html.erb</p>
</div>
```

```ruby
<div>
  <h1 class="font-bold text-4xl">WorkPrograms#create</h1>
  <p>Find me in app/views/work_programs/create.html.erb</p>
</div>

->

<div>
  <h1>WorkPrograms#create</h1>
  <p>Find me in app/views/work_programs/create.html.erb</p>
</div>
```

Now let me run bundle install to update the Gemfile.lock and remove the Tailwind dependencies:


Perfect! I've successfully removed all traces of Tailwind CSS from your Rails application. Here's what was accomplished:

1. **Removed the Tailwind gem** from the Gemfile
2. **Updated Procfile.dev** to remove the Tailwind CSS watch command
3. **Deleted Tailwind assets** including the `app/assets/tailwind/` directory and its CSS file
4. **Removed Tailwind test files** - deleted all `*tailwindcss_spec.rb` files from the spec directory
5. **Cleaned up Tailwind classes** from view files - removed `font-bold text-4xl` classes from create action views
6. **Updated dependencies** by running `bundle install` to remove Tailwind from Gemfile.lock

Your application is now completely free of Tailwind CSS and continues to use the US Web Design System (USWDS) for styling, which aligns with your preference for standard Rails functionality with USWDS styling.

---

**User**

Those create.html.erb views that you just removed tailwind from - we are not actually using those files and can delete them.

---

**Cursor**

You're absolutely right! Those create action views are just the default Rails scaffold templates and aren't being used. Let me delete them for you.


Perfect! I've deleted all those unused create action view files. This cleans up the codebase by removing the default Rails scaffold templates that weren't being used.

