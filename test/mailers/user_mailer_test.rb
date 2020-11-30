require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  test "job_finish" do
    mail = UserMailer.job_finish
    assert_equal "Job finish", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
