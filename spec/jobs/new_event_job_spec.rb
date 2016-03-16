require 'spec_helper'

describe NewEventJob, job: true do
  describe "#perform" do
    let(:password){ 'passWoord' }
    let!(:user){
      user = FactoryGirl.create(:user, password: password)
      user.activate!
      user
    }
    let!(:second_user){
      user = FactoryGirl.create(:user, password: password)
      user.activate!
      user
    }

    let!(:third_user){ FactoryGirl.create(:user, password: password) }

    let(:tour){
      tour = FactoryGirl.create(:tour)
      tour.users << user
      tour.users << second_user
      tour.users << third_user
      tour
    }

    let(:season){ FactoryGirl.create(:season, tour: tour) }

    let(:event){ FactoryGirl.create(:event, season: season) }

    it "does not delivers emails to activated users" do
      TrackUserEventJob.any_instance.expects(:perform)
      expect {
        NewEventJob.new.async.perform(event.id, user.id)
      }.to change{ ActionMailer::Base.deliveries.size }.by(0)
    end
  end
end
