class SorceryMailJob
  include SuckerPunch::Job

  def perform(mailer, method, user)
    ActiveRecord::Base.connection_pool.with_connection do
      #user   = User.find(user_id)
      mail   = mailer.constantize.send(method, user)

      mail.deliver
    end
  end

  def later(sec, mailer, method, user)
    after(sec) { perform(mailer, method, user) }
  end

end
