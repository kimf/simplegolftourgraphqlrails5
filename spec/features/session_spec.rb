require 'spec_helper'

feature "signing in and out" do

  let(:password){ 'passWoord' }
  let!(:user){ FactoryGirl.create(:user, password: password) }

  scenario "user signs in" do
    visit root_path
    click_link "LOG IN"

    fill_in "Email", with: user.email
    fill_in "Password", with: password
    click_button "LOG IN"

    page.should have_content "Logout"
    current_path.should == overview_path
  end

  scenario "user signs out" do
    assure_logged_in(user, password)
    visit root_path

    click_link "Logout"

    page.should have_content "LOG IN"
    current_path.should == root_path
  end
end
