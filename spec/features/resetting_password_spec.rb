require 'spec_helper'

feature "resetting password" do

  let!(:user){ FactoryGirl.create(:user) }

  scenario "asks for email and resets by clicking the link" do
    SorceryMailJob.any_instance.expects(:perform)

    visit login_path
    click_link "Forgot Password?"

    fill_in "Email", with: user.email
    click_button "RESET PASSWORD"
    page.should have_content "Instructions have been sent to your email."

    user.reload
    visit edit_password_reset_url(user.reset_password_token)

    fill_in "New Password", with: 'passwouurd'
    click_button "RESET IT!"
    page.should have_content "Password was successfully updated."

    page.should have_content "Logout"
    current_path.should == overview_path
  end
end
