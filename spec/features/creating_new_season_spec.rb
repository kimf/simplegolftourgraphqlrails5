require 'spec_helper'

feature "creating new season" do
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

  scenario "archives past season and creates a new one" do
    NewSeasonJob.any_instance.expects(:perform)
    visit tour_path(tour)
    click_link "Tour settings"

    click_button "Create new season"

    page.should have_content "Past season was archived and a new season was created"

    tour.reload
    tour.seasons.size.should == 2
  end

end
