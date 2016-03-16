require 'spec_helper'

feature "removing user from tour" do
  let(:password){ 'passWoord' }
  let!(:user){ FactoryGirl.create(:user, password: password) }
  let!(:second_user){ FactoryGirl.create(:user, password: password) }

  let!(:tour) do
    tour = FactoryGirl.create(:tour, creator: user)
    tour.users << user
    tour.users << second_user
    tour
  end

  let!(:season){ FactoryGirl.create(:season, tour: tour) }

  before(:each) do
    #tour.users.map(&:activate!)
    assure_logged_in(user, password)
  end

  scenario "it is possible to remove user from tour" do
    TrackUserEventJob.any_instance.expects(:perform)

    visit tour_path(tour)
    click_link "Members"
    click_link "Remove from tour"
    page.should have_content "#{second_user.name} removed from tour #{tour.name}"

    tour.users.all.should_not include(second_user)
  end
end
