require 'spec_helper'

describe SorceryMailJob, job: true do
  let(:mailer){ 'UserMailer' }
  let(:method){ 'activation_needed_email' }
  let(:user){ FactoryGirl.create(:user) }

  describe "#perform" do
    it "delivers email" do
      expect {
        SorceryMailJob.new.perform(mailer, method, user)
      }.to change{ ActionMailer::Base.deliveries.size }.by(1)
    end
  end

  describe "#later" do
    it "calls perform and delivers email" do
      SorceryMailJob.any_instance.expects(:perform).with(mailer, method, user)
      SorceryMailJob.new.async.later(0, mailer, method, user)
    end
  end
end
