require 'spec_helper'

feature "removing event" do
  let(:password){ 'passWoord' }
  let!(:user){ FactoryGirl.create(:user, password: password) }

  let!(:tour) do
    tour = FactoryGirl.create(:tour, creator: user)
    tour.users << user
    tour
  end

  let!(:season){ FactoryGirl.create(:season, tour: tour) }

  before(:each) do
    #tour.users.map(&:activate!)
    assure_logged_in(user, password)
  end

  scenario "it is possible to cancel an unplayed event" do
    TrackUserEventJob.any_instance.expects(:perform)
    event = Event.create(starts_at: Time.now+2.days, season: season)
    visit tour_event_path(tour, event)

    click_button "Cancel event"
    page.should have_content "Event was canceled"

    tour.reload.events.size.should == 0
  end

  scenario "it is possible to delete a played event" do
    TrackUserEventJob.any_instance.expects(:perform)
    event = Event.create(starts_at: Time.now-2.days, season: season, status: :finished)

    visit tour_event_path(tour, event)
    click_button "Delete event"
    page.should have_content "Event was removed, and leaderboard updated"

    tour.reload.events.size.should == 0
    tour.reload.scores.size.should == 0
  end
end
