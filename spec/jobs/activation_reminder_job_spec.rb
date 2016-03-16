require 'spec_helper'

describe ActivationReminderJob, job: true do
  describe "#perform" do
    let(:password){ 'passWoord' }
    let!(:user){
      user = FactoryGirl.create(:user, password: password)
      user.activate!
      user
    }
    let!(:second_user){
      suser = FactoryGirl.create(:user, password: password, invitor_id: user.id)
      suser
    }

    let(:tour){
      tour = FactoryGirl.create(:tour)
      tour.users << user
      tour.users << second_user
      tour
    }

    it "delivers emails to not activated users" do
      expect {
        ActivationReminderJob.new.async.perform(tour.id)
      }.to change{ ActionMailer::Base.deliveries.size }.by(1)
    end
  end
end
