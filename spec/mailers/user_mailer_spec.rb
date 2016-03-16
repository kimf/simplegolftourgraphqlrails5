require 'spec_helper'

describe UserMailer do

  let!(:user){ FactoryGirl.create(:user) }
  let!(:tour){ FactoryGirl.create(:tour) }
  let!(:season){ FactoryGirl.create(:season, tour: tour) }
  let!(:sender){ FactoryGirl.create(:user) }
  let!(:event){ FactoryGirl.create(:event, season: season) }


  describe 'activation_needed_email' do
    let(:mail) { UserMailer.activation_needed_email(user) }

    it 'renders the subject' do
      mail.subject.should == 'Thanks and welcome to Simple Golftour'
    end

    it 'renders the receiver email' do
      mail.to.should == [user.email]
    end

    it 'renders the sender email' do
      mail.from.should == ['contact@simplegolftour.com']
    end

    it 'assigns @name' do
      mail.body.encoded.should match(user.name)
    end

    it 'assigns @activation_token' do
      mail.body.encoded.should match(user.activation_token)
    end

    it 'tags it for mailgun' do
       mail['X-Mailgun-Tag'].to_s.should == 'welcome_email'
    end
  end

  describe 'activation_needed_reminder_email' do
    before do
      user.invitor_id = sender.id
      tour.users << user
      tour.users << sender
      user.save
    end

    let(:mail) { UserMailer.activation_needed_reminder_email(user, tour) }

    it 'renders the subject' do
      mail.subject.should == "#{sender.name} still wants you to join #{tour.name}"
    end

    it 'renders the receiver email' do
      mail.to.should == [user.email]
    end

    it 'renders the sender email' do
      mail.from.should == ['contact@simplegolftour.com']
    end

    it 'assigns @name' do
      mail.body.encoded.should match(user.name)
    end

    it 'tags it for mailgun' do
       mail['X-Mailgun-Tag'].to_s.should == 'welcome_email_reminder'
    end
  end


  describe 'activation_success_email' do
    context "not admin" do
      let(:mail){ UserMailer.activation_success_email(user) }
      it "does not email" do
        mail.to.should be_nil
      end
    end

    context "when admin" do
      before do
        user.memberships << Membership.create(tour: tour, user: user, role: :admin)
      end

      let(:mail){ UserMailer.activation_success_email(user) }

      it 'renders the subject' do
        mail.subject.should == "You're activated, what now?"
      end

      it 'renders the receiver email' do
        mail.to.should == [user.email]
      end

      it 'renders the sender email' do
        mail.from.should == ['contact@simplegolftour.com']
      end

      it 'tags it for mailgun' do
         mail['X-Mailgun-Tag'].to_s.should == 'activated_email'
      end
    end
  end


  describe 'welcome_from_facebook_email' do
    let(:mail) { UserMailer.welcome_from_facebook_email(user) }

    it 'renders the subject' do
      mail.subject.should == 'Thanks and welcome to Simple Golftour'
    end

    it 'renders the receiver email' do
      mail.to.should == [user.email]
    end

    it 'renders the sender email' do
      mail.from.should == ['contact@simplegolftour.com']
    end

    it 'assigns @name' do
      mail.body.encoded.should match(user.name)
    end

    it 'tags it for mailgun' do
       mail['X-Mailgun-Tag'].to_s.should == 'welcome_from_facebook'
    end
  end

  describe 'reset_password_email' do
    let(:reset_user) { stub(name: 'Lucas S', email: 'lucas@email.com', reset_password_token: 'VHhijEqwcuCqa12i2rbh', reset_password_email_sent_at: Time.now.in_time_zone) }
    let(:mail) { UserMailer.reset_password_email(reset_user) }

    it 'assigns @reset_password_token' do
      mail.body.encoded.should match(reset_user.reset_password_token)
    end

    it 'renders the subject' do
      mail.subject.should == "Here's how to reset your password"
    end

    it 'renders the receiver email' do
      mail.to.should == [reset_user.email]
    end

    it 'renders the sender email' do
      mail.from.should == ['contact@simplegolftour.com']
    end

    it 'assigns @name' do
      mail.body.encoded.should match(reset_user.name)
    end

    it 'tags it for mailgun' do
       mail['X-Mailgun-Tag'].to_s.should == 'reset_password'
    end
  end

  describe 'added_to_tour' do
    let!(:mail){ UserMailer.added_to_tour(user, tour, sender) }

    it 'renders the subject' do
      mail.subject.should == "#{sender.name} added you to #{tour.name}"
    end

    it 'renders the receiver email' do
      mail.to.should == [user.email]
    end

    it 'renders the sender email' do
      mail.from.should == ['contact@simplegolftour.com']
    end

    it 'tags it for mailgun' do
      mail['X-Mailgun-Tag'].to_s.should == 'added_to_tour'
    end
  end

  describe 'new_event' do
    let!(:mail){ UserMailer.new_event(user, event, sender) }

    it 'renders the subject' do
      mail.subject.should == "#{sender.name} added an event in #{tour.name}"
    end

    it 'renders the receiver email' do
      mail.to.should == [user.email]
    end

    it 'renders the sender email' do
      mail.from.should == ['contact@simplegolftour.com']
    end

    it 'tags it for mailgun' do
      mail['X-Mailgun-Tag'].to_s.should == 'new_event'
    end
  end

  describe 'event_reminder' do
    let!(:mail){ UserMailer.event_reminder(user, event) }

    it 'renders the subject' do
      mail.subject.should == "Next event in #{tour.name}: #{event.starts_at.to_s(:short)}"
    end

    it 'renders the receiver email' do
      mail.to.should == [user.email]
    end

    it 'renders the sender email' do
      mail.from.should == ['contact@simplegolftour.com']
    end

    it 'tags it for mailgun' do
      mail['X-Mailgun-Tag'].to_s.should == 'event_reminder'
    end
  end


  describe 'scored_event' do
    let!(:mail){ UserMailer.scored_event(user, event, sender) }

    it 'renders the subject' do
      mail.subject.should == "#{sender.name} scored an event in #{tour.name}"
    end

    it 'renders the receiver email' do
      mail.to.should == [user.email]
    end

    it 'renders the sender email' do
      mail.from.should == ['contact@simplegolftour.com']
    end

    it 'tags it for mailgun' do
      mail['X-Mailgun-Tag'].to_s.should == 'scored_event'
    end
  end

  describe 'role_changed' do
    context 'to admin' do
      let!(:mail){ UserMailer.role_changed(user, :admin, tour, sender) }

      it 'renders the subject' do
        mail.subject.should == "#{sender.name} made you admin in #{tour.name}"
      end

      it 'renders the receiver email' do
        mail.to.should == [user.email]
      end

      it 'renders the sender email' do
        mail.from.should == ['contact@simplegolftour.com']
      end

      it 'tags it for mailgun' do
        mail['X-Mailgun-Tag'].to_s.should == 'changed_role'
      end
    end

    context 'from admin' do
      let!(:mail){ UserMailer.role_changed(user, :player, tour, sender) }

      it 'renders the subject' do
        mail.subject.should == "#{sender.name} removed your admin rights in #{tour.name}"
      end

      it 'renders the receiver email' do
        mail.to.should == [user.email]
      end

      it 'renders the sender email' do
        mail.from.should == ['contact@simplegolftour.com']
      end

      it 'tags it for mailgun' do
        mail['X-Mailgun-Tag'].to_s.should == 'changed_role'
      end
    end
  end


  describe 'new_season' do
    let!(:mail){ UserMailer.new_season(user, tour, sender) }

    it 'renders the subject' do
      mail.subject.should == "#{sender.name} created a new season in #{tour.name}"
    end

    it 'renders the receiver email' do
      mail.to.should == [user.email]
    end

    it 'renders the sender email' do
      mail.from.should == ['contact@simplegolftour.com']
    end

    it 'tags it for mailgun' do
      mail['X-Mailgun-Tag'].to_s.should == 'new_season'
    end
  end

end
