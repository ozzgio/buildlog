require "application_system_test_case"

class EntriesTest < ApplicationSystemTestCase
  test "visiting the public feed without signing in" do
    visit entries_url

    assert_selector "h1", text: "buildlog"
    assert_text entries(:one).body
    assert_link "Send feedback", href: feedback_path
  end

  test "new entry requires sign in" do
    visit new_entry_url

    assert_selector "h1", text: "Sign in"
  end
end
