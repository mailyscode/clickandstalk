class UserMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.job_finish.subject
  #
  def job_finish
    @user = params[:user]
    mail(to: @user.email, subject: 'Your cyber image checkout is done!')
  end
end
