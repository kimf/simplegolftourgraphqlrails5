# == Schema Information
#
# Table name: tours
#
#  id                :integer          not null, primary key
#  name              :string(255)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  custom_domain     :string(255)
#  creator_id        :integer
#  use_custom_domain :boolean          default(FALSE)
#  custom_logo_url   :string(255)
#  info_text         :text
#

FactoryGirl.define do
  factory :tour do
    sequence(:name) {|n| "Tour #{n}" }
    sequence(:custom_domain) {|n| "tour-#{n}"}

    association :creator
  end
end

