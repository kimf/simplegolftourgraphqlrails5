RSpec.configure do |config|
  config.before(:each) { ActionMailer::Base.deliveries.clear }
end

def last_email
  ActionMailer::Base.deliveries.last
end

def email_count
  ActionMailer::Base.deliveries.size
end
