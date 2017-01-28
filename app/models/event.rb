# == Schema Information
#
# Table name: events
#
#  id           :integer          not null, primary key
#  starts_at    :datetime
#  created_at   :datetime
#  updated_at   :datetime
#  status       :integer          default("planned")
#  scoring_type :integer          default("points")
#  team_event   :boolean          default(FALSE)
#  course       :string(255)
#  season_id    :integer
#  course_id    :integer
#  club         :string
#

class Event < ApplicationRecord
  # include LiveLeaderboard
  # date_time_attribute :starts_at

  belongs_to :season
  delegate :tour, to: :season, allow_nil: false

  has_many :scores, dependent: :destroy
  accepts_nested_attributes_for :scores, reject_if: lambda { |i| i[:points].blank? || i[:points].to_i == 0 }

  has_many :users, through: :scores

  has_many :live_scores, dependent: :destroy
  accepts_nested_attributes_for :live_scores, reject_if: lambda { |i| i[:data].blank? }

  has_many :live_users, through: :live_scores, source: :user

  has_many :event_teams, dependent: :destroy
  accepts_nested_attributes_for :event_teams

  validates :starts_at, presence: true
  validates :season_id, presence: true

  enum status:   [ :planned, :finished ]
  enum scoring_type: [ :points, :strokes, :modified_points ]

  default_scope -> { order(:starts_at) }
  scope :planned,     -> { where('status = ?', statuses[:planned]) }
  scope :finished,    -> { where('status = ?', statuses[:finished]) }

  attr_accessor :number_of_players

  def leaderboard
    Score.includes(:user).select(
      "user_id, beers, kr, rank() OVER (ORDER BY event_points DESC), points, event_points"
    ).where(event_id: self.id)
  end

  def lacks_scoring?
    Time.now.in_time_zone > self.starts_at && self.scores.blank?
  end

  def live_scored?
    live_scores.count > 0
  end

  def set_event_points
    self.team_event? ? set_team_event_points : set_individual_event_points
  end

  def update_event_points!
    self.set_event_points
    self.save
  end

  def set_individual_event_points
    ranked_scores = StandardCompetitionRankings.new(
      scores.to_a,
      {rank_by: :points, sort_direction: (strokes? ? :asc : :desc)}
    ).calculate

    points_array = season_points_array(ranked_scores.size)

    points_array.each_with_index do |p, i|
      i = i + 1

      same_position = ranked_scores.select{|r| r.position == i }

      if same_position.size == 1
          same_position.first.event_points = p
      elsif same_position.size > 1
        same_position.each do |r|
          b = r.position-1
          c = b + (same_position.size-1)

          r.event_points = ((points_array[b..c].sum(&:to_f) / same_position.size) * 2).round / 2.0
        end
      end
    end
  end

  def set_team_event_points
    ranked_scores = StandardCompetitionRankings.new(
      event_teams.to_a,
      {rank_by: :points, sort_direction: (strokes? ? :asc : :desc)}
    ).calculate

    team_size = self.event_teams.first.user_ids.size

    if self.season.use_reversed_points?
      size = event_teams.map(&:user_ids).flatten.size
    else
      size = ranked_scores.size
    end

    points_array = season_points_array(size)

    points_array.each_with_index do |p, i|
      i = i + 1

      same_position = ranked_scores.select{|r| r.position == i }

      if same_position.size == 1
          same_position.first.event_points = p
      elsif same_position.size > 1
        same_position.each do |r|
          b = r.position-1
          c = b + (same_position.size-1)

          r.event_points = ((points_array[b..c].sum(&:to_f) / same_position.size) * 2).round / 2.0
        end
      end
    end

    self.event_teams.each do |team|
      team.user_ids.each do |user_id|
        score = self.scores.select{|s| s.user_id == user_id }.first
        if score.nil?
          score = self.scores.build(user_id: user_id, season_id: self.season_id)
        end
        score.assign_attributes(points: team.points, event_points: team.event_points)
      end
    end
  end

  def live_score_cache
    @live_score_cache ||= live_scores
  end

  def set_scores_from_live_scores
    user_ids = live_score_cache.map(&:user_id).uniq
    user_ids.each do |user_id|
      score = self.scores.build(user_id: user_id, season_id: self.season_id)
      users_live_scores = live_score_cache.select{|ls| ls.user_id == user_id }
      if points? || modified_points?
        sum = users_live_scores.sum{|s| s.data["points"] }
      else
        extra_strokes = users_live_scores.sum{|s| s.data["extraStrokes"] }
        total_strokes = users_live_scores.sum{|s| s.data["strokes"] }
        sum = total_strokes - extra_strokes
      end

      earnings = users_live_scores.sum(&:kr)
      beers = users_live_scores.sum(&:beers)

      score.assign_attributes(points: sum, kr: earnings, beers: beers)
    end
  end

  def set_team_scores_from_live_scores
    live_score_cache.group_by(&:team_index).each do |team|
      team_player_ids = team[1].map(&:data).map{|d| d["player_ids"] }.flatten.uniq
      if points? || modified_points?
        sum = team[1].sum{|s| s.data["points"] }
      else
        extra_strokes = team[1].sum{|s| s.data["extraStrokes"] }
        total_strokes = team[1].sum{|s| s.data["strokes"] }
        sum = total_strokes - extra_strokes
      end
      event_teams.build(points: sum, user_ids: team_player_ids)
    end
  end


  protected

  def season_points_array(size)
    if self.season.use_reversed_points?
      base = self.season.points.first.to_i
      add  = self.season.points.second.to_i
      points_array = [base]

      if size == 1
        return points_array
      elsif size == 2
        points_array << (base + add)
      else
        1.upto(size-1){|i| points_array << points_array.last + add }
      end

      return points_array.reverse
    else
      self.season.points.tap do |pa|
        if pa.size < size
          (size - pa.size).times{ pa << 0 }
        end
      end
    end
  end

end
