require 'spec_helper'

describe TrackUserEventJob, job: true do
  describe "#perform" do
    let(:password){ 'passWoord' }
    let!(:user){
      user = FactoryGirl.create(:user, password: password)
      user.activate!
      user
    }

    it "Saves the event to the database" do
      expect {
        TrackUserEventJob.new.async.perform(:logged_in, {user_id: user.id})
      }.to change{ UserEvent.all.size }.by(1)
    end


    context "Admin push notifications" do
      ["scored_event", "invited_user", "created_tour", "signed_up"].each do |event|
        it "notifies admin on #{event}" do
          NotifyAdminJob.any_instance.expects(:perform)
          TrackUserEventJob.new.async.perform(event.to_sym, {user_id: user.id})
        end
      end
    end
  end
end
