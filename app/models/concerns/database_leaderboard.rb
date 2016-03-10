require 'active_support/concern'

module DatabaseLeaderboard
  extend ActiveSupport::Concern
  extend Memoist

  attr_accessor :upto_event

  def database_leaderboard(upto_event=nil)
    query = <<-SQL
      WITH totals AS (
        SELECT
          users.name as name,
          user_id,
          count(scores.event_points) AS events,
          avg(scores.event_points) AS average
        FROM
          scores
        LEFT JOIN
          users ON users.id = scores.user_id
        WHERE
          tour_id = #{self.id}
        GROUP BY
          user_id, users.id
      ) #{prev_totals_with_clause}

      SELECT
        totals.name,
        rank() over (ORDER BY sum(x.event_points) DESC, totals.average DESC),
        max(prev_table.previous_rank) as prev_rank,
        x.user_id,
        max(totals.events) AS events,
        sum(x.event_points) AS total_points,
        round(max(totals.average), 1) AS average,
        array_agg(x.event_points) AS points_array
      FROM (
        SELECT
          user_id,
          tour_id,
          round(event_points, 1) AS event_points,
          row_number() over (partition BY user_id ORDER BY event_points DESC) AS sorted_points
        FROM
          scores
        WHERE
          tour_id = #{self.id}
        ) x
      JOIN
        totals ON x.user_id = totals.user_id
      #{left_join_if_more_events}
      WHERE
        sorted_points <= 5
      AND
        tour_id = #{self.id}
      GROUP BY
        x.user_id, totals.name, totals.average
    SQL

    Score.find_by_sql(query)
  end

  protected

  def left_join_if_more_events
    "LEFT JOIN prev_table ON x.user_id = prev_table.user_id"
  end

  def prev_totals_with_clause
    skip = self.events.size > 1 ? self.events.finished.last.id : 0

    ", prev_totals AS (
      SELECT
        tour_id,
        user_id,
        avg(scores.event_points) AS prev_average
      FROM
        scores
      WHERE
        tour_id = #{self.id}
      AND
        event_id != #{skip}
      GROUP BY
        user_id, tour_id
    ),

    prev_table AS (
      SELECT
      rank() over (ORDER BY sum(y.prev_event_points) DESC, prev_totals.prev_average DESC) AS previous_rank,
      y.user_id,
      round(max(prev_totals.prev_average), 1) AS prev_average,
      array_agg(y.prev_event_points) AS prev_points_array
      FROM (
        SELECT
          user_id,
          round(event_points, 1) AS prev_event_points,
          row_number() over (partition BY user_id ORDER BY event_points DESC) AS sorted_points
        FROM
          scores
        WHERE
          event_id != #{skip}
        ) y
      JOIN
        prev_totals ON y.user_id = prev_totals.user_id
      WHERE
        sorted_points <= 5
      AND
        tour_id = #{self.id}
      GROUP BY
        y.user_id, prev_totals.prev_average
    )"
  end


end
