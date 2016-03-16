# == Schema Information
#
# Table name: users
#
#  id                              :integer          not null, primary key
#  email                           :string(255)      default(""), not null
#  is_public                       :boolean          default(TRUE)
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  swedish                         :boolean          default(FALSE)
#  last_login_at                   :datetime
#  last_logout_at                  :datetime
#  last_activity_at                :datetime
#  last_login_from_ip_address      :string(255)
#  reset_password_token            :string(255)
#  reset_password_token_expires_at :datetime
#  reset_password_email_sent_at    :datetime
#  remember_me_token               :string(255)
#  remember_me_token_expires_at    :datetime
#  crypted_password                :string(255)
#  salt                            :string(255)
#  activation_state                :string(255)
#  activation_token                :string(255)
#  activation_token_expires_at     :datetime
#  first_name                      :string(255)
#  last_name                       :string(255)
#  invitor_id                      :integer
#  partially_registered            :boolean          default(FALSE)
#  name                            :string(255)
#

FactoryGirl.define do

  sequence :email do |n|
    "user#{n}@example.com"
  end

  factory :user do
    name "John Fransman"
    email
    password "password"
    is_public true
    swedish false
  end

  factory :creator, parent: :user do
  end

end
