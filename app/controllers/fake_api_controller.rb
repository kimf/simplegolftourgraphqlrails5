class FakeApiController < ApplicationController
  skip_before_action :authenticate

  def players
    render json: { players: get_players }
  end

  def courses
    render json: { courses: get_courses }
  end

  def authenticate
    render json: get_players[0]
  end

  private

  def get_players
    [
      {
        id: 1,
        name: 'Kim Fransman',
        points: 100,
        rounds: 2,
        average_points: 20.0,
        email: 'kim@fransman.se',
        hcp: 8.5
      },
      {
        id: 2,
        name: 'Christian Högberg',
        points: 90,
        rounds: 2,
        average_points: 15.5,
        email: 'christian@fransman.se',
        hcp: 36.0
      }
    ]
  end

  def get_courses
    [
      {
        name: 'Fors GK',
        par: 70,
        index: 150,
        has_gps: false,
        holes_count: 2,
        lat: "",
        lng: "",
        holes: [
          {
            nr: 1,
            par: 3,
            meters: 160,
            hcp: 9,
            lat: "",
            lng: ""
          },
          {
            nr: 2,
            par: 4,
            meters: 350,
            hcp: 3,
            lat: "",
            lng: ""
          }
        ]
      }
    ]
  end
end
