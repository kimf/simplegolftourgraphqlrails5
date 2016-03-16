ruby "2.3.0"
source "https://rubygems.org"
# Bundle edge Rails instead: gem "rails", github: "rails/rails"
gem "rails", ">= 5.0.0.beta3", "< 5.1"
# Use postgresql as the database for Active Record
gem "pg", "~> 0.18"
# Use Puma as the app server
gem "puma"
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem "jbuilder", "~> 2.0"
# Use Redis adapter to run Action Cable in production
# gem "redis", "~> 3.0"
# Use ActiveModel has_secure_password
# gem "bcrypt", "~> 3.1.7"

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS)
gem "rack-cors"


gem 'haml' #Needed for the emails for now

# Graphql
gem "graphql", github: "rmosolgo/graphql-ruby"
gem "graphql-relay", github: "rmosolgo/graphql-relay-ruby"

gem "email_validator"

gem "memoist"

gem "belongs_to_hstore"

gem "sucker_punch", "~> 1.0"

gem "sorcery"

gem "prowler"

group :development, :test do
  gem "byebug"
  gem "spring-commands-rspec"
  gem "launchy"
end

group :development do
  gem "listen", "~> 3.0.5"
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
  gem "bullet"
  gem "lol_dba"
  gem "letter_opener"
  gem "rails_db_info"
end

group :test do
  gem "rspec-rails"
  gem "rspec-its"
  gem "factory_girl_rails"
  gem "capybara"
  gem "database_cleaner"
  gem "mocha", require: false
end
