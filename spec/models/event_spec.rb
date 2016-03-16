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

require 'spec_helper'

describe Event do
  let(:event){ FactoryGirl.create(:event, scoring_type: :strokes) }

  subject { event }


  context "#lacks_scoring?" do
    describe "when in future" do
      before{ event.update_attribute(:starts_at, Time.now + 2.days) }
      its(:lacks_scoring?){ should eq(false) }
    end

    describe "when in past" do
      before{ event.update_attribute(:starts_at, Time.now - 2.days) }
      its(:lacks_scoring?){ should eq(true) }
    end
  end

  context "Normal points" do

    describe "#set_event_points" do
      before do
        %w(1 2 3 3 5).each do |points|
          FactoryGirl.create(:score, points: points, event: event)
        end
        event.set_event_points
      end

      it "should set event_points" do
        event.scores.map(&:event_points).map(&:to_f).should == [10.0, 8.0, 5.0, 5.0, 2.0]
      end
    end

    context "Team event" do
      describe "#set_event_points" do

        it "should set (team) event_points" do
          first_team_user_ids = []
          second_team_user_ids = []

          2.times do
            first_team_user_ids << FactoryGirl.create(:user, password: 'passwoOOOrd').id
          end

          2.times do
            second_team_user_ids << FactoryGirl.create(:user, password: 'passwoOOOrd').id
          end
          user_id = FactoryGirl.create(:user, password: 'pass').id

          event.scoring_type = :strokes
          event.gametype = 'Greensome'

          event.event_teams.build(user_ids: first_team_user_ids, points: 36)
          event.event_teams.build(user_ids: second_team_user_ids, points: 37)
          event.event_teams.build(user_ids: [user_id], points: 37)

          event.save

          event.update_event_points!

          event.event_teams.map(&:event_points).map(&:to_f).should == [10, 7, 7]

          event.scores.map(&:event_points).map(&:to_f).should == [10, 10, 7, 7, 7]
        end
      end
    end

    describe "#leaderboard" do
      before do
        %w(1 2 3 3 5).each do |points|
          FactoryGirl.create(:score, points: points, event: event)
        end
        event.set_event_points
        event.save
      end

      it "should set the leaderboard" do
        event.scores.map(&:position).should == [1, 2, 3, 3, 5]
      end
    end
  end

  context "Reversed Points" do
    let!(:reversed_season){ FactoryGirl.create(:season, use_reversed_points: true, points: %w(1 1)) }
    let!(:reversed_event){ FactoryGirl.create(:event, season: reversed_season, scoring_type: :strokes) }


    describe "#set_event_points" do
      before do
        %w(1 2 3 3 5).each do |points|
          FactoryGirl.create(:score, points: points, event: reversed_event)
        end
        reversed_event.set_event_points
      end

      it "should set event_points" do
        reversed_event.scores.map(&:event_points).map(&:to_f).should == [5.0, 4.0, 2.5, 2.5, 1.0]
      end
    end

    context "Team event" do
      describe "#set_event_points" do

        it "should set (team) event_points" do
          first_team_user_ids = []
          second_team_user_ids = []

          2.times do
            first_team_user_ids << FactoryGirl.create(:user, password: 'passwoOOOrd').id
          end

          2.times do
            second_team_user_ids << FactoryGirl.create(:user, password: 'passwoOOOrd').id
          end
          user_id = FactoryGirl.create(:user, password: 'pass').id

          reversed_event.scoring_type = :strokes
          reversed_event.gametype = 'Greensome'

          reversed_event.event_teams.build(user_ids: first_team_user_ids, points: 72)
          reversed_event.event_teams.build(user_ids: second_team_user_ids, points: 73)
          reversed_event.event_teams.build(user_ids: [user_id], points: 73)

          reversed_event.save

          reversed_event.update_event_points!

          reversed_event.event_teams.map(&:event_points).map(&:to_f).should == [5, 3.5, 3.5]

          reversed_event.scores.map(&:event_points).map(&:to_f).should == [5, 5, 3.5, 3.5, 3.5]
        end
      end
    end

    describe "#leaderboard" do
      before do
        %w(1 2 3 3 5).each do |points|
          FactoryGirl.create(:score, points: points, event: reversed_event)
        end
        reversed_event.set_event_points
        reversed_event.save
      end

      it "should set the leaderboard" do
        reversed_event.scores.map(&:position).should == [1, 2, 3, 3, 5]
      end
    end

  end
end
