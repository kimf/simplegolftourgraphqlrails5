# == Schema Information
#
# Table name: seasons
#
#  id                  :integer          not null, primary key
#  tour_id             :integer
#  aggregate_count     :integer
#  points              :string(255)      default([]), is an Array
#  closed_at           :datetime
#  created_at          :datetime
#  updated_at          :datetime
#  use_reversed_points :boolean          default(FALSE)
#

class Season < ActiveRecord::Base
  include Leaderboard

  DEFAULT_POINTS_ARRAY = %w(10 8 6 4 2).freeze
  DEFAULT_AGGREGATE_COUNT = 5

  belongs_to :tour
  delegate :users, to: :tour, allow_nil: false

  has_many :events, dependent: :destroy
  has_many :scores, through: :events

  validates :aggregate_count, presence: true, numericality: { greater_than: 0 }
  validates :points, presence: true
  validate  :validate_points_array

  default_scope -> { order(:id) }
  scope :open, -> { where("closed_at IS NULL") }

  def close!
    update_attribute(:closed_at, Time.zone.now)
  end

  def points_ladder
    self[:points].map(&:to_i)
  end

  protected

  def validate_points_array
    if !points.is_a?(Array) || points.select { |a| !a.match(/[^0-9]/) }.empty?
      errors.add(:points, :invalid, message: "Points must be numbers")
    end
  end
end
