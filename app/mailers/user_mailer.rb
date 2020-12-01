class UserMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.job_finish.subject
  #
  def job_finish
    @user = User.first
    mail(
      to: "melik.sak@gmail.com",
      subject: 'Your cyber image checkout is done!'
    )
  end
end
