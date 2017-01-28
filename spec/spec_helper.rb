ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../../config/environment", __FILE__)
require "rspec/rails"
require "rspec/its"
require "capybara/rspec"
require "mocha/api"
require "sucker_punch/testing/inline"

ActiveRecord::Migration.maintain_test_schema!

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

require 'capybara/poltergeist'
Capybara.javascript_driver = :selenium

Capybara.run_server = true #Whether start server when testing
Capybara.server_port = 8123

Capybara.default_host = 'localhost:3100'
Capybara.app_host = "http://localhost:3100"

RSpec.configure do |config|
  config.mock_with :mocha
  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = true

  config.include FactoryGirl::Syntax::Methods
  config.include Sorcery::TestHelpers::Rails::Integration, type: :feature

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  # Clean up all jobs specs with truncation
  config.before(:each, job: true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end

def html_mail_body(mail)
  mail.body.parts.find { |p| p.content_type.match(/html/) }.body.raw_source
end

def plain_mail_body(mail)
  mail.body.parts.find { |p| p.content_type.match(/plain/) }.body.raw_source
end

def assure_logged_in(user, password)
  # login_user(user)
  # page.driver.post '/sessions', user: { email: user.email, password: password }
end

def tour_path(tour)
  "/tours/#{tour.id}"
end

def new_tour_event_path(tour)
  tour_path(tour) + "/events/new"
end
