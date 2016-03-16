require 'spec_helper'

feature "inviting!" do
  let(:password){ 'passWoord' }
  let!(:user){ FactoryGirl.create(:user, password: password) }
  let!(:tour) do
    tour = FactoryGirl.create(:tour, creator: user)
    tour.users << user
    tour
  end

  let!(:season){ FactoryGirl.create(:season, tour: tour) }

  before(:each) do
    assure_logged_in(user, password)
  end

  context "new user" do

    scenario "invites new user" do
      InviteToTourJob.any_instance.expects(:perform)
      visit tour_path(tour)

      click_link "Members"


      fill_in "user_name", with: "Player Playersson"
      fill_in "user_email", with: "player@simplegolftour.com"

      click_button "Add player"

      page.should have_content "Player Playersson has been added to #{tour.name}."

      within "table" do
        page.should have_content "Player Playersson"
      end

      User.where(email: 'player@simplegolftour.com').first.activation_token.should_not be_nil

      check_tour_and_invites(tour.reload, user.reload)
    end

    scenario "invites new user without email" do
      InviteToTourJob.any_instance.expects(:perform).never
      visit tour_path(tour)

      click_link "Members"


      fill_in "user_name", with: "Player Playersonnemail"

      click_button "Add player"

      page.should have_content "Player Playersonnemail has been added to #{tour.name}."

      within "table" do
        page.should have_content "Player Playersonnemail"
      end

      User.where(name: 'Player Playersonnemail').first.email.should == ""

      check_tour_and_invites(tour.reload, user.reload)
    end

    context "second no email user" do
      before(:each) do
        existing = FactoryGirl.create(:user, email: '', invitor: user)
        tour.users << existing
      end

      scenario "invites the second user without email" do
        InviteToTourJob.any_instance.expects(:perform).never
        visit tour_path(tour)

        click_link "Members"

        fill_in "user_name", with: "Player Playersonnemail2"

        click_button "Add player"

        page.should have_content "Player Playersonnemail2 has been added to #{tour.name}."

        within "table" do
          page.should have_content "Player Playersonnemail2"
        end

        User.where(name: 'Player Playersonnemail2').first.email.should == ""

        check_tour_and_invites(tour.reload, user.reload, 3)
      end
    end

    scenario "invites new user and sets a nickname" do
      InviteToTourJob.any_instance.expects(:perform)
      visit tour_path(tour)

      click_link "Members"


      fill_in "user_name", with: "Agoo=wan"
      fill_in "user_email", with: "agowan@simplegolftour.com"

      click_button "Add player"

      page.should have_content "Agoo=wan has been added to #{tour.name}."

      within "table" do
        page.should have_content "Agoo=wan"
      end

      User.where(email: 'agowan@simplegolftour.com').first.activation_token.should_not be_nil

      check_tour_and_invites(tour.reload, user.reload)
    end
  end

  context "invites existing user" do
    let!(:user_one){
      user = FactoryGirl.create(:user, password: password)
      user.activate!
      user
    }

    scenario "invites existing users" do
      InviteToTourJob.any_instance.expects(:perform)

      visit tour_path(tour)
      click_link "Members"

      fill_in "user_name", with: "Player1 Playersson"
      fill_in "user_email", with: user_one.email

      click_button "Add player"

      page.should have_content "Player1 Playersson has been added to #{tour.name}."

      within "table" do
        page.should have_content user_one.short_name
      end

      user_one.reload
      tour.reload

      tour.users.count.should == 2

      user.inviteds.to_a.should_not include(user_one)

      user_one.tours.should include(tour)
      user_one.invitor.should be_nil
    end

    scenario "invites existing users and sets nickname" do
      InviteToTourJob.any_instance.expects(:perform)

      visit tour_path(tour)
      click_link "Members"

      fill_in "user_name", with: "Floober"
      fill_in "user_email", with: user_one.email

      click_button "Add player"

      page.should have_content "Floober has been added to #{tour.name}."

      within "table" do
        page.should have_content user_one.short_name_for(tour)
      end

      user_one.reload
      tour.reload

      tour.users.count.should == 2

      user.inviteds.to_a.should_not include(user_one)

      user_one.tours.should include(tour)
      user_one.invitor.should be_nil
    end
  end


  context "errors and such" do
    let!(:user_three){
      user = FactoryGirl.create(:user, password: password)
      user.activate!
      user
    }

    scenario "validation fails" do
      visit tour_path(tour)
      click_link "Members"


      fill_in "user_name", with: ""
      fill_in "user_email", with: "newplayer@simplegolftour"

      click_button "Add player"

      page.should have_content "Could not add player, check input!"
    end
  end

  context "from scoring screen" do
    let!(:event){ FactoryGirl.create(:event, season: season, starts_at: Time.now.in_time_zone-2.hours, scoring_type: :points) }

    scenario "invites user" do
      InviteToTourJob.any_instance.expects(:perform)
      visit tour_path(tour)
      click_link "Events"
      click_link "Score"

      click_link "New player"

      fill_in "Name", with: "Player0 Playersson"
      fill_in "Email", with: "player0@simplegolftour.com"

      click_button "Add player"

      page.should have_content "Player0 Playersson has been added to #{tour.name}."

      click_link "I'm done, lets score"

      page.should have_button "Save scores"

      within "form" do
        page.should have_content "Player0 P"
      end

      User.last.activation_token.should_not be_nil

      check_tour_and_invites(tour.reload, user.reload, 2)
    end

    scenario "invites user without email" do
      InviteToTourJob.any_instance.expects(:perform).never
      visit tour_path(tour)
      click_link "Events"
      click_link "Score"

      click_link "New player"

      fill_in "Name", with: "Player0 Playersson"

      click_button "Add player"

      page.should have_content "Player0 Playersson has been added to #{tour.name}."

      click_link "I'm done, lets score"

      page.should have_button "Save scores"

      within "form" do
        page.should have_content "Player0 P"
      end

      User.last.email.should == ""

      check_tour_and_invites(tour.reload, user.reload, 2)
    end
  end

  context "already invited" do
    let!(:user_four){
      user = FactoryGirl.create(:user, password: password)
      tour.users << user
      user
    }

    scenario "it does not send the invite" do
      InviteToTourJob.any_instance.expects(:perform).never

      visit tour_path(tour)
      click_link "Members"

      fill_in "user_name", with: "Player1 Playersson"
      fill_in "user_email", with: user_four.email

      click_button "Add player"

      page.should have_content "A player with that email (#{user_four.name}) is already a member of this tour"

      tour.users.count.should == 2
    end
  end

  scenario "do not invite self" do
    InviteToTourJob.any_instance.expects(:perform).never

    visit tour_path(tour)
    click_link "Members"

    fill_in "user_email", with: user.email

    click_button "Add player"

    page.should have_content "You can't invite yourself, duh!"

    user.memberships.count.should == 1
    user.tours.count.should == 1
  end

  def check_tour_and_invites(tour, user, count=2)
    tour.users.count.should == count

    new_users = tour.users.select{|u| u != user}

    new_users.each do |u|
      u.invitor_id.should eq(user.id)
      u.activation_token.should_not be_nil
    end

    user.inviteds.to_a.map(&:id).should eq(new_users.map(&:id))
  end
end
