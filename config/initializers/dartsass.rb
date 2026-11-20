
# Configure Dart Sass for Prairie Fashion Boutique.
#
# Compile both the customer-facing storefront stylesheet
# and the ActiveAdmin dashboard stylesheet.

Rails.application.config.dartsass.builds = {
  "application.scss" => "application.css",
  "active_admin.scss" => "active_admin.css"
}
