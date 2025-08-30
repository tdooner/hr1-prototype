# Move checkboxes into UswdsFormBuilder
_Exported on 8/30/2025 at 16:18:40 PDT from Cursor (1.5.7)_

---

**User**

Can you move the checkboxes into UswdsFormBuilder as well?

---

**Cursor**

I'll help you move the checkboxes into the UswdsFormBuilder. Let me first examine the current form to see what checkboxes need to be moved.


I can see that this form is using radio buttons, not checkboxes. Let me check the UswdsFormBuilder to see what methods are already available and understand the current structure.


I can see that the UswdsFormBuilder already has a `check_box` method, but it's quite basic. Let me also check if there are any other forms in the application that use checkboxes to understand the pattern better.


Let me examine one of these forms to see how checkboxes are currently being used:


Now I can see the pattern! The checkboxes are currently being used with manual HTML structure. I need to enhance the UswdsFormBuilder to include a proper `check_box` method that follows the same pattern as the other form elements. Let me update the UswdsFormBuilder:


```ruby
  def check_box(method, label_text, hint_text = nil, options = {}, checked_value = "1", unchecked_value = "0")
    render_checkbox_group(method, label_text, hint_text) do
      add_error_class_to_options!(method, options)
      super(method, options, checked_value, unchecked_value)
    end
  end

// ... existing code ...

  private

  def render_form_group(method, label_text, hint_text = nil)
    error_class = has_errors?(method) ? "usa-form-group--error" : ""
    css_class = ["usa-form-group", error_class].compact.join(" ")
    
    @template.content_tag(:div, class: css_class) do
      safe_join([
        label(method, label_text, class: "usa-label"),
        hint_text ? hint_element(method, hint_text) : nil,
        yield,
        error_message_for(method)
      ].compact)
    end
  end

  def render_checkbox_group(method, label_text, hint_text = nil)
    error_class = has_errors?(method) ? "usa-form-group--error" : ""
    css_class = ["usa-form-group", error_class].compact.join(" ")
    
    @template.content_tag(:div, class: css_class) do
      safe_join([
        hint_text ? hint_element(method, hint_text) : nil,
        @template.content_tag(:div, class: "usa-checkbox") do
          yield + label(method, label_text, class: "usa-checkbox__label")
        end,
        error_message_for(method)
      ].compact)
    end
  end
```

Now I need to update the checkbox method to add the proper USWDS class to the checkbox input:


```ruby
  def check_box(method, label_text, hint_text = nil, options = {}, checked_value = "1", unchecked_value = "0")
    render_checkbox_group(method, label_text, hint_text) do
      add_error_class_to_options!(method, options)
      super(method, options, checked_value, unchecked_value)
    end
  end

->

  def check_box(method, label_text, hint_text = nil, options = {}, checked_value = "1", unchecked_value = "0")
    render_checkbox_group(method, label_text, hint_text) do
      add_error_class_to_options!(method, options)
      # Always add usa-checkbox__input class
      options[:class] = [options[:class], "usa-checkbox__input"].compact.join(" ")
      super(method, options, checked_value, unchecked_value)
    end
  end
```

Now let me update the questions form to use the new UswdsFormBuilder checkbox method:


```ruby
    <%= form_with model: @engagement_form, url: engagement_form_questions_path(@engagement_form), method: :post, local: true, class: "usa-form", builder: UswdsFormBuilder do |form| %>
      
      <fieldset class="usa-fieldset">
        <legend class="usa-legend--large">Check any of these that apply:</legend>
        
        <%= form.check_box :has_job, "I have a job", nil, {}, "yes", "no" %>
        <%= form.check_box :is_student, "I am a student", nil, {}, "yes", "no" %>
        <%= form.check_box :enrolled_work_program, "I am enrolled in a work program", nil, {}, "yes", "no" %>
        <%= form.check_box :volunteers_nonprofit, "I volunteer with a nonprofit organization", nil, {}, "yes", "no" %>
      </fieldset>
```

Now let me update the other form that uses checkboxes:


```ruby
    <%= form_with model: @engagement_form, url: update_engagement_types_engagement_form_path(@engagement_form), method: :patch, local: true, class: "usa-form", builder: UswdsFormBuilder do |form| %>
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
        <legend class="usa-legend--large">Select all that apply:</legend>
        
        <%= form.check_box :has_job, "I have a job" %>
        <%= form.check_box :is_student, "I am a student" %>
        <%= form.check_box :enrolled_work_program, "I am enrolled in a work program" %>
        <%= form.check_box :volunteers_nonprofit, "I volunteer with a nonprofit organization" %>
      </fieldset>
```

Perfect! I've successfully moved the checkboxes into the UswdsFormBuilder. Here's what I accomplished:

1. **Enhanced the UswdsFormBuilder** with a proper `check_box` method that follows the same pattern as other form elements
2. **Added proper USWDS styling** with the `usa-checkbox__input` class and proper HTML structure
3. **Updated both forms** that were using checkboxes to use the new UswdsFormBuilder method

The new `check_box` method in UswdsFormBuilder now:
- Takes a label text parameter (like other form elements)
- Supports optional hint text
- Automatically applies USWDS classes
- Handles error states consistently
- Generates the proper HTML structure with `usa-checkbox` wrapper

The forms are now much cleaner and more consistent with the rest of the application's form patterns.

---

**User**

Great. Now, I'd like you to update the styling for all checkboxes to be the "tile" variant, which entails adding a "usa-checkbox__input--tile" class to the <input>.

---

**Cursor**

I'll update the UswdsFormBuilder to add the tile variant class to all checkboxes. This will make them display as tile-style checkboxes.


```ruby
      # Always add usa-checkbox__input class
      options[:class] = [options[:class], "usa-checkbox__input"].compact.join(" ")

->

      # Always add usa-checkbox__input and usa-checkbox__input--tile classes
      options[:class] = [options[:class], "usa-checkbox__input", "usa-checkbox__input--tile"].compact.join(" ")
```

Perfect! I've updated the UswdsFormBuilder to automatically add the `usa-checkbox__input--tile` class to all checkboxes. Now all checkboxes throughout the application will display as tile-style checkboxes, which provide a more prominent and visually appealing interface for users to make their selections.

The change affects all forms that use the UswdsFormBuilder's `check_box` method, including the questions form and engagement types form we just updated.

---

**User**

They should actually not be surrounded in a usa-form-group.

---

**Cursor**

I'll update the UswdsFormBuilder to remove the `usa-form-group` wrapper from checkboxes since they should be standalone elements.


```ruby
  def render_checkbox_group(method, label_text, hint_text = nil)
    error_class = has_errors?(method) ? "usa-form-group--error" : ""
    css_class = ["usa-form-group", error_class].compact.join(" ")
    
    @template.content_tag(:div, class: css_class) do
      safe_join([
        hint_text ? hint_element(method, hint_text) : nil,
        @template.content_tag(:div, class: "usa-checkbox") do
          yield + label(method, label_text, class: "usa-checkbox__label")
        end,
        error_message_for(method)
      ].compact)
    end
  end

->

  def render_checkbox_group(method, label_text, hint_text = nil)
    @template.content_tag(:div, class: "usa-checkbox") do
      safe_join([
        hint_text ? hint_element(method, hint_text) : nil,
        yield + label(method, label_text, class: "usa-checkbox__label"),
        error_message_for(method)
      ].compact)
    end
  end
```

Perfect! I've updated the `render_checkbox_group` method to remove the `usa-form-group` wrapper. Now checkboxes will be rendered as standalone `usa-checkbox` elements without the form group container, which is the correct approach for tile-style checkboxes in USWDS.

---

**User**

Great, please do the same thing for radio buttons. The <input> should have a "usa-radio__input--tile" class.

---

**Cursor**

I'll update the UswdsFormBuilder to add the tile variant class to radio buttons as well.


```ruby
      super(method, collection, value_method, label_method, options, html_options) do |builder|
        @template.content_tag(:div, class: "usa-radio") do
          builder.radio_button(class: "usa-radio__input") + 
          builder.label(class: "usa-radio__label")
        end
      end

->

      super(method, collection, value_method, label_method, options, html_options) do |builder|
        @template.content_tag(:div, class: "usa-radio") do
          builder.radio_button(class: "usa-radio__input usa-radio__input--tile") + 
          builder.label(class: "usa-radio__label")
        end
      end
```

Perfect! I've updated the `collection_radio_buttons` method to add the `usa-radio__input--tile` class to all radio button inputs. Now both checkboxes and radio buttons throughout the application will display as tile-style elements, providing a consistent and visually appealing interface for user selections.

