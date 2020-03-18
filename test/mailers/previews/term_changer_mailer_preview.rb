class TermChangeMailerPreview < ActionMailer::Preview

  def inform
    TermChangeMailer.inform User.first.nickname
  end
end
