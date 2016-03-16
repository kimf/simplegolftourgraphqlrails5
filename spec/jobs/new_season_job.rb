require 'spec_helper'

describe NewSeasonJob, job: true do
  describe "#perform" do
    let(:password){ 'passWoord' }
    let!(:user){
      user = FactoryGirl.create(:user, password: password)
      user.activate!
      user
    }
    let!(:changer){
      user = FactoryGirl.create(:user, password: password)
      user.activate!
      user
    }

    let!(:tour){
      tour = FactoryGirl.create(:tour)
      tour.users << user
      tour.users << changer
      tour
    }

    let!(:season){ FactoryGirl.create(:season, tour: tour) }

    it "delivers emails to activated users" do
      TrackUserEventJob.any_instance.expects(:perform).once

      expect {
        NewSeasonJob.new.async.perform(tour.id, changer.id)
      }.to change{ ActionMailer::Base.deliveries.size }.by(1)
    end
  end
end
