require 'spec_helper'

feature "event scoring" do
  let(:password){ 'passWoord' }
  let!(:user){ FactoryGirl.create(:user, password: password, name: "Kim F") }

  let!(:user_one){ FactoryGirl.create(:user, password: password, name: "Daniel G") }
  let!(:user_two){ FactoryGirl.create(:user, password: password, name: "Fredrik B") }

  let!(:tour) do
    tour = FactoryGirl.create(:tour, creator: user)
    tour.users << [user, user_one, user_two]
    tour.save
    tour
  end

  let!(:season){ FactoryGirl.create(:season, tour: tour, points: %w(20 10 5 2)) }

  let!(:reversed_tour) do
    tour = FactoryGirl.create(:tour, creator: user)
    tour.users << [user, user_one, user_two]
    tour.save
    tour
  end

  let!(:reversed_season){ FactoryGirl.create(:season, tour: reversed_tour, points: %w(1 2), use_reversed_points: true) }


  before(:each) do
    tour.users.map(&:activate!)
    assure_logged_in(user, password)
  end

  context "Normal points" do

    context "Stableford" do
      let!(:event){ FactoryGirl.create(:event, season: season, starts_at: Time.now.in_time_zone-2.hours, scoring_type: :points) }


      scenario "adding scores" do
        EventScoredJob.any_instance.expects(:perform)
        visit tour_path(tour)
        click_link "Events"
        click_link "Score"

        fill_in "event_scores_attributes_0_points", with: 40
        fill_in "event_scores_attributes_1_points", with: 36
        fill_in "event_scores_attributes_2_points", with: 36

        click_button "Save scores"

        page.should have_content "Scores was saved. who won?"

        event.reload.finished?.should == true

        within("table") do
          page.should have_content "40"
          page.should have_content "36"

          page.should have_content "20.0p"
          page.should have_content "7.5p"
        end
      end
    end

    context "Stroke play" do
      let!(:event){ FactoryGirl.create(:event, season: season, starts_at: Time.now.in_time_zone-2.hours, scoring_type: :strokes) }

      scenario "adding scores" do
        EventScoredJob.any_instance.expects(:perform)
        visit tour_path(tour)
        click_link "Events"
        click_link "Score"

        fill_in "event_scores_attributes_0_points", with: 72
        fill_in "event_scores_attributes_1_points", with: 72
        fill_in "event_scores_attributes_2_points", with: 83

        click_button "Save scores"

        page.should have_content "Scores was saved. who won?"

        event.reload.finished?.should == true

        within("table") do
          page.should have_content "72"
          page.should have_content "83"

          page.should have_content "15.0p"
          page.should have_content "5.0p"
        end
      end
    end

    context "Team event" do
      let!(:event){ FactoryGirl.create(:event, season: season, starts_at: Time.now.in_time_zone-2.hours, scoring_type: :strokes, team_event: true) }

      scenario "adding scores" do
        EventScoredJob.any_instance.expects(:perform)
        visit tour_path(tour)
        click_link "Events"
        click_link "Score"

        within(".team_0") do
          check user.name
          check user_one.name
        end

        within(".team_1") do
          check user_two.name
        end

        click_button "Next"

        fill_in "event_event_teams_attributes_0_points", with: 36
        fill_in "event_event_teams_attributes_1_points", with: 37

        click_button "Save scores"

        page.should have_content "Scores was saved. who won?"

        event.reload.tap do |e|
          e.finished?.should == true
        end

        EventTeam.all.size.should == 2

        EventTeam.first.tap do |et|
          et.event.should == event
          et.user_ids.should include(user.id, user_one.id)
          et.event_points.to_f.should == 20.0
          et.points.should == 36
        end

        EventTeam.last.tap do |et|
          et.event.should == event
          et.user_ids.should == [user_two.id]
          et.event_points.to_f.should == 10.0
          et.points.should == 37
        end

        within("table") do
          page.should have_content "36"
          page.should have_content "37"

          page.should have_content "20.0 p"
          page.should have_content "10.0 p"
        end
      end
    end

  end

  context "Reversed points" do
    context "Stableford" do
      let!(:reversed_event){ FactoryGirl.create(:event, season: reversed_season, starts_at: Time.now.in_time_zone-2.hours, scoring_type: :points) }


      scenario "adding scores" do
        EventScoredJob.any_instance.expects(:perform)
        visit tour_path(reversed_tour)
        click_link "Events"
        click_link "Score"

        fill_in "event_scores_attributes_0_points", with: 40
        fill_in "event_scores_attributes_1_points", with: 40
        fill_in "event_scores_attributes_2_points", with: 36

        click_button "Save scores"

        page.should have_content "Scores was saved. who won?"

        reversed_event.reload.finished?.should == true

        within("table") do
          page.should have_content "40"
          page.should have_content "36"

          page.should have_content "4.0p"
          page.should have_content "1.0p"
        end
      end
    end

    context "Stroke play" do
      let!(:reversed_event){ FactoryGirl.create(:event, season: reversed_season, starts_at: Time.now.in_time_zone-2.hours, scoring_type: :strokes) }

      scenario "adding scores" do
        EventScoredJob.any_instance.expects(:perform)
        visit tour_path(reversed_tour)
        click_link "Events"
        click_link "Score"

        fill_in "event_scores_attributes_0_points", with: 72
        fill_in "event_scores_attributes_1_points", with: 73
        fill_in "event_scores_attributes_2_points", with: 83

        click_button "Save scores"

        page.should have_content "Scores was saved. who won?"

        reversed_event.reload.finished?.should == true

        within("table") do
          page.should have_content "72"
          page.should have_content "73"
          page.should have_content "83"

          page.should have_content "5.0p"
          page.should have_content "3.0p"
          page.should have_content "1.0p"
        end
      end
    end

    context "Team event" do
      let!(:reversed_event){ FactoryGirl.create(:event, season: reversed_season, starts_at: Time.now.in_time_zone-2.hours, scoring_type: :strokes, team_event: true) }

      scenario "adding scores" do
        EventScoredJob.any_instance.expects(:perform)
        visit tour_path(reversed_tour)
        click_link "Events"
        click_link "Score"

        within(".team_0") do
          check user.name
          check user_one.name
        end

        within(".team_1") do
          check user_two.name
        end

        click_button "Next"

        fill_in "event_event_teams_attributes_0_points", with: 36
        fill_in "event_event_teams_attributes_1_points", with: 37

        click_button "Save scores"

        page.should have_content "Scores was saved. who won?"

        reversed_event.reload.tap do |e|
          e.finished?.should == true
        end

        EventTeam.all.size.should == 2

        EventTeam.first.tap do |et|
          et.event.should == reversed_event
          et.user_ids.should include(user.id, user_one.id)
          et.event_points.to_f.should == 5.0
          et.points.should == 36
        end

        EventTeam.last.tap do |et|
          et.event.should == reversed_event
          et.user_ids.should == [user_two.id]
          et.event_points.to_f.should == 3.0
          et.points.should == 37
        end

        within("table") do
          page.should have_content "36"
          page.should have_content "37"

          page.should have_content "5.0p"
          page.should have_content "3.0p"
        end
      end
    end
  end
end
