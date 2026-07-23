require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "downcases and strips email_address" do
    user = User.new(email_address: " DOWNCASED@EXAMPLE.COM ")
    assert_equal("downcased@example.com", user.email_address)
  end

  test "email has a server-side length cap" do
    user = User.new(email_address: "#{"a" * User::EMAIL_MAX_LENGTH}@example.com", password: "password")

    assert_not user.valid?
    assert_includes user.errors[:email_address], "is too long (maximum is #{User::EMAIL_MAX_LENGTH} characters)"
  end

  test "password has a server-side length cap" do
    user = User.new(email_address: "bounded@example.com", password: "a" * (User::PASSWORD_MAX_LENGTH + 1))

    assert_not user.valid?
    assert_includes user.errors[:password], "is too long (maximum is #{User::PASSWORD_MAX_LENGTH} characters)"
  end
end
