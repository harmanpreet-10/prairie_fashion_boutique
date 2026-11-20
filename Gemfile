
source "https://rubygems.org"

# Ruby on Rails
gem "rails", "~> 8.1.4", ">= 8.1.4.1"

# Asset pipeline
gem "propshaft"

# Database
gem "sqlite3", ">= 2.1"

# Web server
gem "puma", ">= 5.0"

# JavaScript
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"

# JSON APIs
gem "jbuilder"

# Admin dashboard and authentication
gem "devise"
gem "activeadmin"
gem "dartsass-rails"

# Windows timezone support
gem "tzinfo-data", platforms: %i[windows jruby]

# Rails database-backed adapters
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

# Performance
gem "bootsnap", require: false

# Deployment
gem "kamal", require: false
gem "thruster", require: false

# Image processing
gem "image_processing", "~> 1.2"

group :development, :test do
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"
  gem "bundler-audit", require: false
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
end

group :development do
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
end

gem "kaminari", "~> 1.3"
