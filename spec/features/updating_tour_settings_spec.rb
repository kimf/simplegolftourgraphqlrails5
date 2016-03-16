require 'spec_helper'

feature "updating tour settings" do
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

  context "regular points" do
    it "updates the tour settings" do
      points_arr = ["20","15","10","8","6","4","2","0","0","0","0","0"]
      TrackUserEventJob.any_instance.expects(:perform)
      visit tour_path(tour)
      click_link "Tour settings"


      points_arr.each_with_index do |point, index|
        fill_in "tour_points_#{index+1}", with: point
      end

      click_button "Save"

      page.should have_content "Tour settings changed"

      tour.reload
      tour.seasons.size.should == 1
      tour.current_season.points.should == points_arr
    end
  end

  context "reversed points" do
    it "updates the tour settings" do
      points_arr = ["1","1"]
      TrackUserEventJob.any_instance.expects(:perform)
      visit tour_path(tour)
      click_link "Tour settings"

      check  "Use reversed points"

      points_arr.each_with_index do |point, index|
        fill_in "tour_reversed_points_#{index}", with: point
      end

      click_button "Save"

      page.should have_content "Tour settings changed"

      tour.reload
      tour.seasons.size.should == 1
      tour.current_season.use_reversed_points?.should == true
      tour.current_season.points.should == points_arr
    end
  end

end
