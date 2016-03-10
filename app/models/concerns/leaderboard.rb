require 'active_support/concern'

module Leaderboard
  extend ActiveSupport::Concern
  extend Memoist

  attr_accessor :upto_event

  def leaderboard(upto_event=nil)
    @upto_event = upto_event

    if events_to_use.size > 1
      rankings.each do |player|
        player.prev_position = prev_rankings.select{|p| p.id == player.id }.first.prev_position
      end
    else
      rankings.each{ |p| p.prev_position = 0 }
    end
  end

  def rankings
    StandardCompetitionRankings.new(players, {rank_by: :total_points, dealbreaker: :average}).calculate
  end

  def prev_rankings
    StandardCompetitionRankings.new(players, {set: :prev_position, rank_by: :old_total_points, dealbreaker: :old_average}).calculate
  end

  def players
    @players = []
    users.each do |user|
      user.num_events   = user_scores(user.id).length
      user.average      = average_for_user(user.id)
      user.points_array = best_five_for_user(user.id).collect(&:event_points)
      user.total_points = best_five_for_user(user.id).sum(&:event_points)

      user.old_average      = events_to_use.size > 1 ? average_for_user(user.id, true) : 0
      user.old_total_points = events_to_use.size > 1 ? best_five_for_user(user.id, true).sum(&:event_points) : 0

      if user.num_events > 0
        @players << user
      end
    end

    @players
  end
  #memoize :players

  def events_to_use
    if @upto_event.nil?
      events_to_use = finished_event_ids
    else
      events_to_use = finished_event_ids.select{|e| e <= @upto_event }
    end
  end
  #memoize :events_to_use

  def finished_event_ids
    @finished_event_ids ||= events.finished.map(&:id)
  end

  def cached_scores
    @cached_scores ||= scores.where(event_id: events_to_use) #.select{|s| events_to_use.include?(s.event_id) }
  end
  #memoize :cached_scores

  def user_scores(user_id, exclude_last=false)
    @user_scores = cached_scores.select{|s| s.user_id == user_id }
    if exclude_last
      @user_scores = @user_scores.reject{|s| s.event_id == events_to_use.last }
    end
    @user_scores
  end
  #memoize :user_scores

  def best_five_for_user(user_id, exclude_last=false)
    user_scores(user_id, exclude_last).sort_by(&:event_points).reverse.take(5)
  end
  #memoize :best_five_for_user

  def average_for_user(user_id, exclude_last=false)
    avg = (user_scores(user_id, exclude_last).sum(&:event_points).to_f / user_scores(user_id, exclude_last).length.to_f)
    if avg.nan?
      avg = 0.0
    end
    (avg*2).round / 2.0
  end
  #memoize :average_for_user

end
