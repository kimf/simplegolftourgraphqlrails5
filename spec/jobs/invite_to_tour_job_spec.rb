require 'spec_helper'

describe InviteToTourJob, job: true do
  describe "#perform" do
    let(:password){ 'passWoord' }
    let!(:sender){ FactoryGirl.create(:user, password: password) }

    let!(:user){ FactoryGirl.create(:user) }

    let!(:tour){ FactoryGirl.create(:tour) }

    it "delivers emails to activated users" do
      TrackUserEventJob.any_instance.expects(:perform)
      expect {
        InviteToTourJob.new.async.perform(user.id, tour.id, sender.id)
      }.to change{ ActionMailer::Base.deliveries.size }.by(1)
    end
  end
end
