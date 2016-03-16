require 'spec_helper'

feature "managing user roles" do
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

  let!(:third_user) do
    user = FactoryGirl.create(:user, password: password)
    tour.users << user
    membership = user.membership_for(tour)
    membership.role = :admin
    membership.save
    user.reload
  end

  before(:each) do
    #tour.users.map(&:activate!)
    assure_logged_in(user, password)
  end



  scenario "it is possible to make a user admin" do
    RoleChangedJob.any_instance.expects(:perform)

    visit tour_path(tour)
    click_link "Members"
    click_link "Make admin"
    page.should have_content "#{second_user.name} is now admin in tour #{tour.name}"

    second_user.has_role?(:admin, tour).should eq(true)
  end

  scenario "it is possible to remove admin from a user" do
    RoleChangedJob.any_instance.expects(:perform)

    visit tour_path(tour)
    click_link "Members"
    click_link "Remove admin rights"
    page.should have_content "#{third_user.name} is not admin anymore"

    third_user.has_role?(:admin, tour).should eq(false)
  end
end
