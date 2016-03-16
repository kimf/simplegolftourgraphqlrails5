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

require 'spec_helper'

describe User do

  let(:tour){ create(:tour) }
  let(:tour2){ create(:tour) }

  let(:user2){ create(:user, tours: [tour]) }
  let(:user3){ create(:user, tours: [tour]) }
  let(:user4){ create(:user, tours: [tour2]) }

  let(:user){ create(:user, email: 'EmaiL@DomaiN.No', tours: [tour]) }


  subject { user }

  describe "#downcase_email" do
    before{ user.downcase_email }
    its(:email){ should eq("email@domain.no") }
  end

  context "Friending" do
    its(:friend_ids){ should include(user2.id) }
    its(:friend_ids){ should include(user3.id) }

    its(:friend_ids){ should_not include(user4.id) }
    its(:friend_ids){ should_not include(user.id) }
  end

end
