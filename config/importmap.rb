# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin "@uswds/uswds", to: "@uswds--uswds.js" # @3.13.0
pin_all_from "app/javascript/controllers", under: "controllers"
