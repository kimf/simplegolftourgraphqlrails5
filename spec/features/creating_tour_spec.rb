require 'spec_helper'

feature "creating tour" do
  let(:password){ 'passWoord' }
  let!(:user){ FactoryGirl.create(:user, password: password) }

  before(:each) do
    assure_logged_in(user, password)
  end

  scenario "user creates his first tour" do
    TrackUserEventJob.any_instance.expects(:perform)
    visit root_path

    page.should have_content "Let's create your tour"

    fill_in "Title", with: "Tisdagsgolfen"
    fill_in "Subdomain", with: "tisdagsgolfen"
    fill_in "How many events should be aggregated?", with: 3
    fill_in "tour_points_1", with: 20
    fill_in "tour_points_2", with: 15
    fill_in "tour_points_3", with: 10
    fill_in "tour_points_4", with: 8
    fill_in "tour_points_5", with: 6
    fill_in "tour_points_6", with: 4
    fill_in "tour_points_7", with: 2

    click_button "Create tour"

    page.should have_content "Tisdagsgolfen"

    page.should have_content "Oh no, It seems you are all alone in your tour Invite some friends"

    click_link "Members"

    within("table") do
      page.should have_content user.name
      page.should have_content "Tour owner"
    end

    Tour.last.creator.should == user
    Tour.last.seasons.size.should == 1
  end

  scenario "Creating with reversed points" do
    TrackUserEventJob.any_instance.expects(:perform)
    visit root_path

    page.should have_content "Let's create your tour"

    fill_in "Title", with: "Tisdagsgolfen"
    fill_in "Subdomain", with: "tisdagsgolfen"

    check  "Use reversed points"

    fill_in "tour_reversed_points_0", with: 1
    fill_in "tour_reversed_points_1", with: 2

    click_button "Create tour"

    page.should have_content "Tisdagsgolfen"

    Tour.last.current_season.use_reversed_points.should == true
    Tour.last.seasons.size.should == 1
    Tour.last.current_season.points.should == ["1","2"]
  end

  context "after first tour is created" do
    before do
      season = FactoryGirl.create(:season, tour: FactoryGirl.create(:tour, name: 'Hej'))
      user.tours << season.tour
    end

    scenario "creates more tours" do

      TrackUserEventJob.any_instance.expects(:perform)
      visit root_path

      page.should_not have_content "Let's create your tour"

      page.should have_content "Hej"

      click_link "+ New tour"

      page.should_not have_content "Create new tour"

      fill_in "Title", with: "Onsdagsgolfen"
      fill_in "Subdomain", with: "onsdagsgolfen"
      fill_in "How many events should be aggregated?", with: 3
      fill_in "tour_points_1", with: 20
      fill_in "tour_points_2", with: 15
      fill_in "tour_points_3", with: 10
      fill_in "tour_points_4", with: 8
      fill_in "tour_points_5", with: 6
      fill_in "tour_points_6", with: 4
      fill_in "tour_points_7", with: 2

      click_button "Create tour"

      page.should have_content "Onsdagsgolfen"

      click_link "Members"

      within("table") do
        page.should have_content user.name
        page.should have_content "Tour owner"
      end

      Tour.last.creator.should == user
      Tour.last.seasons.size.should == 1

    end

  end
end
