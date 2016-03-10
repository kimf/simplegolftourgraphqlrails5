# == Schema Information
#
# Table name: events
#
#  id           :integer          not null, primary key
#  starts_at    :datetime
#  created_at   :datetime
#  updated_at   :datetime
#  status       :integer          default(0)
#  scoring_type :integer          default(0)
#  team_event   :boolean          default(FALSE)
#  course       :string(255)
#  gametype     :string(255)
#  season_id    :integer
#
class Event < ActiveRecord::Base
  belongs_to :season
  delegate :tour, to: :season, allow_nil: false

  has_many :scores, dependent: :destroy
  accepts_nested_attributes_for :scores,
                                reject_if: -> (i) { i[:points].blank? || i[:points].to_i == 0 }

  has_many :users, through: :scores

  has_many :event_teams, dependent: :destroy
  accepts_nested_attributes_for :event_teams

  validates :starts_at, presence: true
  validates :season_id, presence: true

  # TODO: Turn this into model? belongs_to :gametype, possible to do special
  # calculation rules in the database
  INDIVIDUAL_GAMETYPES = ["Stableford", "Stroke Play"].freeze
  TEAM_GAMETYPES = ["Scramble", "Best Ball", "Four Ball", "Greensome", "Foursome"].freeze

  before_validation :setup_gametype

  enum status:   [:planned, :finished]
  enum scoring_type: [:points, :strokes]

  default_scope -> { order(:starts_at) }
  # scope :planned,     -> { where("status = ?", statuses[:planned]) }
  # scope :finished,    -> { where("status = ?", statuses[:finished]) }

  attr_accessor :number_of_players

  def leaderboard
    Score.includes(:user).select("user_id,
      rank() OVER (ORDER BY event_points DESC), points, event_points").where(event_id: id)
  end

  def lacks_scoring?
    Time.now.in_time_zone > starts_at && scores.blank?
  end

  def set_event_points
    team_event? ? set_team_event_points : set_individual_event_points
  end

  def update_event_points!
    set_event_points
    save!
  end

  def set_individual_event_points
    ranked_scores = StandardCompetitionRankings.new(
      scores.to_a,
      rank_by: :points, sort_direction: (points? ? :desc : :asc)
    ).calculate

    points_array = season_points_array(ranked_scores.size)

    points_array.each_with_index do |p, i|
      i += 1

      same_position = ranked_scores.select { |r| r.position == i }

      if same_position.size == 1
        same_position.first.event_points = p
      elsif same_position.size > 1
        same_position.each do |r|
          b = r.position - 1
          c = b + (same_position.size - 1)

          r.event_points = ((points_array[b..c].sum(&:to_f) / same_position.size) * 2).round / 2.0
        end
      end
    end
  end

  def set_team_event_points
    ranked_scores = StandardCompetitionRankings.new(
      event_teams.to_a,
      rank_by: :points, sort_direction: (points? ? :desc : :asc)
    ).calculate

    size = if season.use_reversed_points?
             event_teams.map(&:user_ids).flatten.size
           else
             ranked_scores.size
           end

    points_array = season_points_array(size)

    points_array.each_with_index do |p, i|
      i += 1

      same_position = ranked_scores.select { |r| r.position == i }

      if same_position.size == 1
        same_position.first.event_points = p
      elsif same_position.size > 1
        same_position.each do |r|
          b = r.position - 1
          c = b + (same_position.size - 1)

          r.event_points = ((points_array[b..c].sum(&:to_f) / same_position.size) * 2).round / 2.0
        end
      end
    end

    event_teams.each do |team|
      team.user_ids.each do |user_id|
        score = scores.find { |s| s.user_id == user_id }
        if score.nil?
          score = scores.build(user_id: user_id, season_id: season_id)
        end
        score.assign_attributes(points: team.points, event_points: team.event_points)
      end
    end
  end

  protected

  def season_points_array(size)
    if season.use_reversed_points?
      base = season.points.first.to_i
      add  = season.points.second.to_i
      points_array = [base]

      return points_array if size == 1

      if size == 2
        points_array << (base + add)
      else
        1.upto(size - 1) { points_array << points_array.last + add }
      end

      return points_array.reverse
    else
      season.points.tap do |pa|
        (size - pa.size).times { pa << 0 } if pa.size < size
      end
    end
  end

  def setup_gametype
    self.team_event = TEAM_GAMETYPES.include?(gametype)
    self.scoring_type = :strokes if gametype == "Stroke Play"
  end
end
