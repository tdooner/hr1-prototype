# Update button layout on summary page
_Exported on 9/1/2025 at 16:40:16 PDT from Cursor (1.5.9)_

---

**User**

On the summary#show page (after the form is submitted), update the "Submit Another Form" button to be in a usa-button-group with the other one.

---

**Cursor**

I'll help you update the "Submit Another Form" button to be in a usa-button-group with the other button on the summary#show page. Let me first examine the current file to see the structure and then make the necessary changes.


I can see this is the review page, but I need to find the summary#show page where the form has been submitted. Let me search for the summary show view.


Now let me read the summary show view to see the current structure and locate the "Submit Another Form" button.


Perfect! I can see the current structure. There are two buttons at the bottom:
1. A "Download PDF" button (only shown when completed)
2. A "Submit Another Form" button

I need to wrap these buttons in a `usa-button-group` to group them together. Let me update the file:


```erb
    <div class="usa-form-group">
      <% if @engagement_form.completed? %>
        <%= link_to "Download PDF", pdf_download_path(format: :pdf), class: "usa-button" %>
      <% end %>
      <%= link_to "Submit Another Form", new_engagement_form_path, class: "usa-button usa-button--outline" %>
    </div>

->

    <div class="usa-form-group">
      <div class="usa-button-group">
        <% if @engagement_form.completed? %>
          <%= link_to "Download PDF", pdf_download_path(format: :pdf), class: "usa-button" %>
        <% end %>
        <%= link_to "Submit Another Form", new_engagement_form_path, class: "usa-button usa-button--outline" %>
      </div>
    </div>
```

Perfect! I've updated the summary#show page to wrap both buttons in a `usa-button-group`. Now the "Submit Another Form" button will be properly grouped with the "Download PDF" button (when it's visible) using the USWDS button group styling, which will provide better visual organization and spacing between the buttons.

---

**User**

Almost. THe button group needs to be a <ul> and each button within an <li> with the usa-button-group__item class

---

**Cursor**

You're absolutely right! The USWDS button group should use a `<ul>` structure with `<li>` elements. Let me fix that:


```erb
    <div class="usa-form-group">
      <div class="usa-button-group">
        <% if @engagement_form.completed? %>
          <%= link_to "Download PDF", pdf_download_path(format: :pdf), class: "usa-button" %>
        <% end %>
        <%= link_to "Submit Another Form", new_engagement_form_path, class: "usa-button usa-button--outline" %>
      </div>
    </div>

->

    <div class="usa-form-group">
      <ul class="usa-button-group">
        <% if @engagement_form.completed? %>
          <li class="usa-button-group__item">
            <%= link_to "Download PDF", pdf_download_path(format: :pdf), class: "usa-button" %>
          </li>
        <% end %>
        <li class="usa-button-group__item">
          <%= link_to "Submit Another Form", new_engagement_form_path, class: "usa-button usa-button--outline" %>
        </li>
      </ul>
    </div>
```

Perfect! Now the button group follows the proper USWDS structure with `<ul class="usa-button-group">` and each button wrapped in `<li class="usa-button-group__item">` elements. This will provide the correct styling and spacing for the button group.

