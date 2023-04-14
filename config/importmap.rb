# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@hotwired/turbo-rails", to: "@hotwired--turbo-rails.js" # @7.3.0
pin "@hotwired/stimulus", to: "@hotwired--stimulus.js" # @3.2.1
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin "@rails/actioncable", to: "@rails--actioncable.js" # @7.0.4
pin "morphdom" # @2.6.1
pin "lodash.debounce" # @4.0.8
pin "cable_ready" # @5.0.0
pin "stimulus_reflex" # @3.5.0
pin_all_from "app/javascript/controllers", under: "controllers"
pin_all_from "app/javascript/channels", under: "channels"
pin_all_from "app/javascript/config", under: "config"
pin "@hotwired/turbo", to: "@hotwired--turbo.js" # @7.3.0
pin "@rails/actioncable/src", to: "@rails--actioncable--src.js" # @7.0.4
