require 'spec_helper'

feature "signing up" do

  before(:each) do
    ActionMailer::Base.deliveries.clear
  end

  scenario "user signs up" do
    TrackUserEventJob.any_instance.expects(:perform)
    SorceryMailJob.any_instance.expects(:later)

    visit root_path

    fill_in "user[name]", with: 'Jonathan Lundgren'
    fill_in "user[email]", with: 'MyEmail@Domain.CoM'
    fill_in "user[password]", with: 'passWooord'

    click_button "START COMPETING"

    @user = User.last
    page.should have_content "#{@user.name}"
    page.should_not have_css ".activation_nudge"
  end

  describe "activation_nudge" do
    before do
      user = FactoryGirl.create(:user, password: 'password', activation_token: 'aasadasd')
      season = FactoryGirl.create(:season)
      season.tour.users << user
      user.update_attribute(:created_at, Date.today - 2.days)
      assure_logged_in(user, 'password')
    end

    it "shows after 2 days" do
      visit root_path
      page.should have_css ".activation_nudge"
    end
  end


  describe "Activation" do
    let(:activation_token){ "VHhijEqwcuCqa12i2rbh" }
    let!(:user){ FactoryGirl.create(:user, password: 'password', activation_token: activation_token) }
    let!(:invited_user){
      user = FactoryGirl.build(:user, password: nil, activation_token: activation_token, partially_registered: true)
      user.save
      user
    }

    scenario "user activates account" do
      TrackUserEventJob.any_instance.expects(:perform)
      SorceryMailJob.any_instance.expects(:later)

      visit activate_user_url(user.activation_token)

      page.should have_content "Thanks for activating!"
      page.should_not have_css ".activation_nudge"
    end

    scenario "when invited and dont have password" do
      TrackUserEventJob.any_instance.expects(:perform)
      SorceryMailJob.any_instance.expects(:later)

      visit activate_user_url(invited_user.activation_token)

      page.should have_content "HELLO #{invited_user.name.upcase} PLEASE CHOOSE A PASSWORD"

      fill_in "user[password]", with: 'passWooord'

      click_button "ACTIVATE ACCOUNT"

      page.should have_content "Thanks for activating!"
      page.should_not have_css ".activation_nudge"
    end
  end

end
