# Community Engagement Prototype - Development Context

## Project Overview

**Application Name:** Community Engagement Prototype  
**Purpose:** Multi-page form application to help users meet "Community Engagement Requirements"  
**Core Functionality:** Collects user information, saves to database, generates formatted PDF output

## Technical Stack

### Backend
- **Framework:** Ruby on Rails 8.0.2.1
- **Database:** PostgreSQL with Active Record
- **PDF Generation:** WickedPDF + wkhtmltopdf-binary
- **Testing:** RSpec with FactoryBot and Faker

### Frontend
- **JavaScript:** Minimal custom JS, relies on Rails Turbo for SPA-like behavior
- **Styling:** USWDS (US Web Design System) via CDN
- **Form Handling:** Standard Rails form helpers with Turbo

## Application Architecture

### Multi-Page Form Flow
1. **Initial Form** (`/engagement_forms/new`) - Basic user info (name, email)
2. **Questions Page** (`/questions/new`) - Single page with all "yes/no" engagement type questions
3. **Detail Pages** - Conditional routing based on user selections:
   - Jobs (`/jobs/new`) - Employment details with paycheck management
   - Students (`/students/new`) - Student details  
   - Work Programs (`/work_programs/new`) - Work program details
   - Volunteers (`/volunteers/new`) - Volunteer shifts list and management
4. **Summary Page** (`/summary/:id`) - Complete overview with PDF download

### Volunteer Management Flow
1. **Volunteers Page** (`/volunteers/new`) - Lists all volunteer shifts with total hours
2. **Add Volunteer Shift** (`/volunteer_shifts/new`) - Form to add new shift with organization, date, and hours
3. **Return to Volunteers** - After saving, user returns to see updated list
4. **Continue to Summary** - Proceeds to final review with all shifts displayed

### Paycheck Management Flow
1. **Jobs Page** (`/jobs/new`) - Lists all paychecks with total hours and gross pay
2. **Add Paycheck** (`/job_paychecks/new`) - Form to add new paycheck with pay date, gross pay, and hours
3. **Return to Jobs** - After saving, user returns to see updated list
4. **Continue to Summary** - Proceeds to final review with all paychecks displayed

### Key Design Decisions

#### Conditional Routing Strategy
- **Problem:** Initially tried JavaScript for dynamic field visibility
- **Solution:** Server-side conditional routing to separate detail pages
- **Benefit:** Cleaner separation of concerns, better validation control

#### Validation Approach
- **Problem:** Model-level validation caused errors on initial form submission
- **Solution:** Controller-level validation for step-specific requirements
- **Benefit:** Better user experience, prevents premature validation errors

#### PDF Generation
- **Problem:** Template naming conflicts with Rails format expectations
- **Solution:** Use `show.pdf.erb` template with proper WickedPDF configuration
- **Benefit:** Consistent PDF output with professional formatting

## Database Schema

### EngagementForm Model
```ruby
# Core fields
user_name: string
email: string

# Engagement type flags
has_job: boolean
is_student: boolean
enrolled_work_program: boolean
volunteers_nonprofit: boolean

# Detail fields
school_name: string
enrollment_status: string
school_hours: decimal
work_program_name: string
hours_attended: decimal

# Associations
has_many :volunteer_shifts, dependent: :destroy
has_many :job_paychecks, dependent: :destroy
```

### VolunteerShift Model
```ruby
# Fields
engagement_form_id: references
organization_name: string
shift_date: date
hours: decimal

# Associations
belongs_to :engagement_form

# Validations
validates :organization_name, presence: true
validates :shift_date, presence: true
validates :hours, presence: true, numericality: { greater_than: 0 }

# Scopes
scope :ordered_by_date, -> { order(shift_date: :desc) }
```

### JobPaycheck Model
```ruby
# Fields
engagement_form_id: references
pay_date: date
gross_pay_amount: decimal
hours_worked: decimal

# Associations
belongs_to :engagement_form

# Validations
validates :pay_date, presence: true
validates :gross_pay_amount, presence: true, numericality: { greater_than: 0 }
validates :hours_worked, presence: true, numericality: { greater_than: 0 }

# Scopes
scope :ordered_by_date, -> { order(pay_date: :desc) }
```

## Requirements Verification System

### EngagementRequirementsVerifier Service
A service class that determines whether an Engagement Form meets the Medicaid Community Engagement Requirements.

#### Requirements Logic
A user meets the requirements if they satisfy **any one** of these conditions:
1. **Enrolled half-time or more in school** - Automatic qualification
2. **Gross monthly income ≥ $580** - Based on job paychecks in prior month
3. **Total hours ≥ 80** - Combined from:
   - Work hours (from job paychecks)
   - School hours (only if enrolled less than half-time)
   - Work program hours
   - Volunteer hours

#### Service Methods
```ruby
# Main verification
verifier = EngagementRequirementsVerifier.new(engagement_form)
verifier.meets_requirements? # => true/false

# Detailed breakdown
verifier.verification_details # => Hash with all calculations
```

#### Convenience Methods on EngagementForm
```ruby
engagement_form.meets_requirements? # => true/false
engagement_form.verification_details # => Hash with all calculations
```

#### Unused Data Tracking
The verifier tracks data that falls outside the prior month and provides detailed information about what wasn't used:

```ruby
details = verifier.verification_details
unused_data = details[:unused_data]

# Example structure:
{
  job_paychecks: {
    count: 2,
    total_income: 1800.0,
    total_hours: 180.0,
    months: ["June 2025", "July 2025"]
  },
  volunteer_shifts: {
    count: 1,
    total_hours: 100.0,
    months: ["May 2025"]
  }
}
```

#### Key Features
- **Month-based calculations** - All income and hours calculated for the month prior to application date
- **Flexible hour counting** - School hours only count if enrolled less than half-time
- **Comprehensive testing** - 30+ test cases covering all scenarios and edge cases
- **Detailed reporting** - Returns breakdown of all calculations for transparency
- **Unused data tracking** - Identifies and reports data from other months that wasn't used for verification

## Key Controllers

### EngagementFormsController
- `new` - Initial form
- `create` - Saves basic info, redirects to questions
- `show` - Displays form data (HTML/PDF formats)

### QuestionsController  
- `new` - Single page with all engagement type questions
- `create` - Saves boolean flags, conditionally routes to detail pages
- `skip?` - Class method that always returns false (first step)

### Detail Controllers (Jobs, Students, WorkPrograms, Volunteers)
- `new` - Detail input form
- `create` - Saves details, routes to next relevant page or summary
- `skip?` - Class method that determines if the controller should be skipped based on engagement form state

### VolunteerShiftsController
- `new` - Form to add a new volunteer shift
- `create` - Saves volunteer shift and redirects back to volunteers page
- Handles validation errors and success messages

### JobPaychecksController
- `new` - Form to add a new paycheck
- `create` - Saves paycheck and redirects back to jobs page
- Handles validation errors and success messages

### SummaryController
- `show` - Final summary with PDF download link

## Dynamic Routing System

### Overview
The application uses a centralized routing system in `ApplicationController` that dynamically determines the next step in the form flow based on the current controller and the engagement form's state.

### Implementation

#### Controller Order
```ruby
CONTROLLER_ORDER = [
  QuestionsController,
  JobsController,
  StudentsController,
  WorkProgramsController,
  VolunteersController
].freeze
```

#### Skip Logic
Each controller implements a `skip?` class method that determines whether it should be skipped:

```ruby
# JobsController
def self.skip?(engagement_form)
  !engagement_form.has_job?
end

# StudentsController  
def self.skip?(engagement_form)
  !engagement_form.is_student?
end

# WorkProgramsController
def self.skip?(engagement_form)
  !engagement_form.enrolled_work_program?
end

# VolunteersController
def self.skip?(engagement_form)
  !engagement_form.volunteers_nonprofit?
end
```

#### Next Path Method
The `next_path` method in `ApplicationController` finds the current controller's position in the order and returns the path to the next non-skipped controller:

```ruby
def next_path(engagement_form, current_controller_class = self.class)
  current_index = CONTROLLER_ORDER.index(current_controller_class)
  
  # If current controller is not in the order, or we're at the end, go to summary
  return review_summary_path(engagement_form.id) if current_index.nil? || current_index == CONTROLLER_ORDER.length - 1
  
  # Find the next controller that should not be skipped
  next_index = current_index + 1
  while next_index < CONTROLLER_ORDER.length
    next_controller = CONTROLLER_ORDER[next_index]
    unless next_controller.skip?(engagement_form)
      return send("new_engagement_form_#{next_controller.name.underscore.gsub('_controller', '')}_path", engagement_form)
    end
    next_index += 1
  end
  
  # If no next controller found, go to summary
  review_summary_path(engagement_form.id)
end
```

### Benefits
- **Centralized Logic:** All routing logic is in one place
- **Maintainable:** Adding new steps only requires updating the order array and adding a skip method
- **Testable:** Comprehensive test coverage for all routing scenarios
- **Flexible:** Easy to change the order or skip conditions

## Routes Configuration

```ruby
# Main form flow
resources :engagement_forms, only: [:new, :create, :show]
resources :questions, only: [:new, :create]

# Detail flows  
resources :jobs, only: [:new, :create]
resources :students, only: [:new, :create]
resources :work_programs, only: [:new, :create]
resources :volunteers, only: [:new, :create]
resources :volunteer_shifts, only: [:new, :create]
resources :job_paychecks, only: [:new, :create]

# Summary
get "summary/:engagement_form_id", to: "summary#show", as: :summary
```

## PDF Generation Setup

### WickedPDF Configuration
```ruby
# config/initializers/wicked_pdf.rb
WickedPdf.config = {
  layout: "pdf",
  orientation: "portrait", 
  page_size: "letter",
  margin: { top: 20, bottom: 20, left: 20, right: 20 }
}
```

### PDF Template Structure
- **Layout:** `app/views/layouts/pdf.html.erb` - PDF-specific styling
- **Template:** `app/views/engagement_forms/show.pdf.erb` - Content template
- **Features:** Professional formatting, conditional sections, complete data display
- **Volunteer Data:** Structured table showing volunteer shifts with organization, date, hours, and total

## Styling Implementation

### USWDS Integration
- **Method:** CDN links (avoided gem due to Rails 8 compatibility issues)
- **Files:** `app/views/layouts/application.html.erb`
- **Components:** Forms, buttons, alerts, grid system

### Key CSS Classes Used
- `usa-form` - Form styling
- `usa-button` - Button styling  
- `usa-alert` - Success/error messages
- `usa-section` - Page sections
- `grid-container` - Layout containers

## Testing Strategy

### RSpec Setup
- **Framework:** RSpec with FactoryBot for test data
- **Coverage:** Request specs for all controller actions
- **Factories:** EngagementForm factory with realistic test data

### Test Structure
```ruby
# Example: spec/requests/engagement_forms_spec.rb
RSpec.describe "EngagementForms", type: :request do
  describe "GET /engagement_forms/new" do
    it "returns a successful response" do
      get new_engagement_form_path
      expect(response).to be_successful
    end
  end
end
```

## Development Environment

### Setup Commands
```bash
# Install Rails locally
gem install rails --user-install
export PATH="$HOME/.local/share/gem/ruby/3.4.0/bin:$PATH"

# Start server
rails server -p 3000
```

### Code Quality & Style
```bash
# Run RuboCop to check code style
bundle exec rubocop

# Auto-fix correctable style issues
bundle exec rubocop -a

# Check specific files or directories
bundle exec rubocop app/controllers/
bundle exec rubocop spec/
```

**Important:** Always run `bundle exec rubocop` after making changes to verify that style lints are fixed. This ensures code consistency and follows the established style guidelines.

### Key Dependencies
```ruby
# Gemfile additions
gem "rspec-rails"
gem "factory_bot_rails" 
gem "faker"
gem "wicked_pdf"
gem "wkhtmltopdf-binary"
```

## Common Issues & Solutions

### 1. Rails Command Not Found
- **Issue:** `rbenv: rails: command not found`
- **Solution:** Install Rails with `--user-install` flag and update PATH

### 2. USWDS Gem Compatibility
- **Issue:** Dependency conflicts with Rails 8
- **Solution:** Use CDN links instead of gem

### 3. PDF Template Missing
- **Issue:** `Missing template engagement_forms/pdf`
- **Solution:** Use `show.pdf.erb` template with proper format handling

### 4. Validation Errors on First Page
- **Issue:** Model validation running on initial form
- **Solution:** Move validation to controller level for step-specific logic

## Future Enhancement Opportunities

### Potential Improvements
1. **Form Validation:** Add client-side validation with Turbo
2. **Progress Indicators:** Visual progress bar through form steps
3. **Data Export:** Additional export formats (CSV, Excel)
4. **User Authentication:** User accounts and form history
5. **Admin Interface:** Dashboard for viewing all submissions
6. **Volunteer Shift Management:** Edit/delete functionality for volunteer shifts
7. **Bulk Import:** CSV import for volunteer shifts
8. **Paycheck Management:** Edit/delete functionality for paychecks

### Technical Debt
1. **Error Handling:** More robust error pages and validation messages
2. **Performance:** Database indexing for larger datasets
3. **Security:** Input sanitization and CSRF protection review
4. **Accessibility:** ARIA labels and keyboard navigation improvements

## Deployment Considerations

### Production Requirements
- **Database:** PostgreSQL with proper indexing
- **PDF Generation:** wkhtmltopdf binary installation
- **Assets:** USWDS CDN or local asset compilation
- **Environment:** Rails production environment configuration

### Security Notes
- **Input Validation:** All form inputs validated and sanitized
- **File Downloads:** PDF generation uses secure file handling
- **Session Management:** Standard Rails session security

---

*This document captures the key technical decisions and implementation details from the development session. It serves as a reference for future development, maintenance, and potential enhancements to the Community Engagement Prototype application.*
