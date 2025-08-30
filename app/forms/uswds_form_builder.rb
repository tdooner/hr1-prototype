class UswdsFormBuilder < ActionView::Helpers::FormBuilder
  include ActionView::Helpers::TagHelper
  def text_field(method, label_text, hint_text = nil, options = {})
    render_form_group(method, label_text, hint_text) do
      add_error_class_to_options!(method, options)
      super(method, options)
    end
  end

  def email_field(method, label_text, hint_text = nil, options = {})
    render_form_group(method, label_text, hint_text) do
      add_error_class_to_options!(method, options)
      super(method, options)
    end
  end

  def number_field(method, label_text, hint_text = nil, options = {})
    render_form_group(method, label_text, hint_text) do
      add_error_class_to_options!(method, options)
      super(method, options)
    end
  end

  def date_field(method, label_text, hint_text = nil, options = {})
    render_form_group(method, label_text, hint_text) do
      add_error_class_to_options!(method, options)
      super(method, options)
    end
  end

  def text_area(method, label_text, hint_text = nil, options = {})
    render_form_group(method, label_text, hint_text) do
      add_error_class_to_options!(method, options)
      super(method, options)
    end
  end

  def select(method, label_text, choices = nil, hint_text = nil, options = {}, html_options = {})
    render_form_group(method, label_text, hint_text) do
      add_error_class_to_options!(method, html_options)
      super(method, choices, options, html_options)
    end
  end

  def radio_button(method, tag_value, options = {})
    add_error_class_to_options!(method, options)
    super
  end

  def check_box(method, options = {}, checked_value = "1", unchecked_value = "0")
    add_error_class_to_options!(method, options)
    super
  end

  def collection_radio_buttons(method, collection, value_method, label_method, options = {}, html_options = {})
    render_form_group(method, options[:label_text], options[:hint_text]) do
      add_radio_error_class_to_options!(method, html_options)
      super(method, collection, value_method, label_method, options, html_options) do |builder|
        @template.content_tag(:div, class: "usa-radio") do
          builder.radio_button(class: "usa-radio__input") + 
          builder.label(class: "usa-radio__label")
        end
      end
    end
  end

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

  def hint_element(method, hint_text)
    @template.content_tag(:div, hint_text, class: "usa-hint", id: "#{method}-hint")
  end

  def has_errors?(method)
    object.respond_to?(:errors) && object.errors[method].any?
  end

  def add_error_class_to_options!(method, options)
    # Always add usa-input class
    options[:class] = [options[:class], "usa-input"].compact.join(" ")
    
    if has_errors?(method)
      # Add error class to the input field
      options[:class] = [options[:class], "usa-input--error"].compact.join(" ")
      
      # Add error message ID to aria-describedby
      existing_aria = options[:'aria-describedby']
      error_id = "#{method}-error"
      
      if existing_aria
        # If there's already aria-describedby, append the error ID
        aria_ids = existing_aria.split(/\s+/)
        aria_ids << error_id unless aria_ids.include?(error_id)
        options[:'aria-describedby'] = aria_ids.join(" ")
      else
        options[:'aria-describedby'] = error_id
      end
    end
  end

  def add_radio_error_class_to_options!(method, options)
    if has_errors?(method)
      # Add error message ID to aria-describedby
      existing_aria = options[:'aria-describedby']
      error_id = "#{method}-error"
      
      if existing_aria
        # If there's already aria-describedby, append the error ID
        aria_ids = existing_aria.split(/\s+/)
        aria_ids << error_id unless aria_ids.include?(error_id)
        options[:'aria-describedby'] = aria_ids.join(" ")
      else
        options[:'aria-describedby'] = error_id
      end
    end
  end

  def error_message_for(method)
    return unless has_errors?(method)
    
    error_message = object.errors[method].first
    @template.content_tag(:div, 
      @template.content_tag(:span, error_message, class: "usa-error-message"), 
      id: "#{method}-error", 
      class: "usa-error-message"
    )
  end
end
