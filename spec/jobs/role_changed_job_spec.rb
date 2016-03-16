require 'spec_helper'

describe RoleChangedJob, job: true do
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

    let(:tour){
      tour = FactoryGirl.create(:tour)
      tour.users << user
      tour.users << changer
      tour
    }

    it "delivers emails to activated users" do
      TrackUserEventJob.any_instance.expects(:perform).twice

      expect {
        RoleChangedJob.new.async.perform(user.id,  tour.id, :admin, changer.id)
      }.to change{ ActionMailer::Base.deliveries.size }.by(1)
      expect {
        RoleChangedJob.new.async.perform(user.id,  tour.id, :player, changer.id)
      }.to change{ ActionMailer::Base.deliveries.size }.by(1)
    end
  end
end
