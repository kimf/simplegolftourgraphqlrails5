require 'spec_helper'

feature "creating event", js: true do
  let(:password){ 'passWoord' }
  let!(:user){ FactoryGirl.create(:user, password: password) }

  let!(:user_one){ FactoryGirl.create(:user, password: password) }
  let!(:user_two){ FactoryGirl.create(:user, password: password) }

  let!(:tour) do
    tour = FactoryGirl.create(:tour, creator: user)
    tour.users << user
    tour.users << user_one
    tour.users << user_two
    tour
  end

  let!(:season){ FactoryGirl.create(:season, tour: tour) }

  before(:each) do
    #tour.users.map(&:activate!)
    assure_logged_in(user, password)
  end

  scenario "adds the first event" do
    NewEventJob.any_instance.expects(:perform)
    visit tour_path(tour)
    page.should have_link "Add the first event"

    click_link "Events"
    page.should_not have_link "Add event"

    fill_in "Starts at", with: (Time.now.in_time_zone + 1.week).to_s

    fill_in "Course", with: 'Pebble Beach'

    choose "Stableford"#, from: 'Gametype'

    click_button "Create event"

    page.should have_content "Event was created."

    page.should have_content (Time.now.in_time_zone + 1.week).strftime('%A %e %b, %H:%M')
    page.should have_content "Stableford"
    page.should have_content "Pebble Beach"


    Event.last.tap do |e|
      e.team_event?.should eq(false)
      e.points?.should eq(true)
      e.strokes?.should eq(false)
    end

  end

  scenario "Add strokes event" do
    NewEventJob.any_instance.expects(:perform)
    visit new_tour_event_path(tour)

    fill_in "Starts at", with: (Time.now.in_time_zone + 1.week).to_s

    fill_in "Course", with: 'Pebble Beach'

    choose "Stroke Play"

    click_button "Create event"

    page.should have_content "Event was created."

    page.should have_content (Time.now.in_time_zone + 1.week).strftime('%A %e %b, %H:%M')
    page.should have_content "Stroke Play"
    page.should have_content "Pebble Beach"


    Event.last.tap do |e|
      e.team_event?.should eq(false)
      e.points?.should eq(false)
      e.strokes?.should eq(true)
    end

  end

  context "Team events" do
    scenario "adds a team event" do
      NewEventJob.any_instance.expects(:perform)
      visit new_tour_event_path(tour)

      fill_in "Starts at", with: (Time.now.in_time_zone + 2.hours).to_s

      fill_in "Course", with: 'Pebble Beach'

      choose "Greensome"#, from: 'Gametype'
      choose "strokes"#, from: 'Scoring type'

      click_button "Create event"

      page.should have_content (Time.now.in_time_zone + 2.hours).strftime('%A %e %b, %H:%M')
      page.should have_content "Greensome"
      page.should have_content "Strokes"
      page.should have_content "Pebble Beach"

      Event.last.tap do |e|
        e.team_event?.should eq(true)
        e.points?.should eq(false)
        e.strokes?.should eq(true)
      end
    end
  end

  context "after first event is created" do
    before do
      season.events << Event.create(starts_at: Time.now.in_time_zone, season: season)
    end

    scenario "adds more events" do
      NewEventJob.any_instance.expects(:perform)
      visit tour_path(tour)
      page.should_not have_link "Add the first event"

      click_link "Events"
      click_link "Add event"

      fill_in "Starts at", with: (Time.now.in_time_zone + 2.hours).to_s

      fill_in "Course", with: 'Pebble Beach'

      choose "Scramble"#, from: 'Gametype'
      choose "strokes"#, from: 'Scoring type'

      click_button "Create event"

      page.should have_content "Event was created."

      page.should have_content (Time.now.in_time_zone + 2.hours).strftime('%A %e %b, %H:%M')
      page.should have_content "Scramble"
      page.should have_content "Strokes"
      page.should have_content "Pebble Beach"

      Event.last.tap do |e|
        e.team_event?.should eq(true)
        e.points?.should eq(false)
        e.strokes?.should eq(true)
      end
    end
  end

end
