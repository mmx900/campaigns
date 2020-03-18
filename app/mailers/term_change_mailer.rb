class TermChangeMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.term_change_mailer.inform.subject
  #
  def inform message
    @greeting = "Hi"
    @message = message
    mail to: "to@example.org"
  end
end
