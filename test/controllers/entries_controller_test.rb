require "test_helper"

class EntriesControllerTest < ActionDispatch::IntegrationTest
  test "index renders the public feed without authentication" do
    get entries_url
    assert_response :success
  end

  test "feed renders a valid RSS document" do
    get feed_url
    assert_response :success
    assert_equal "application/rss+xml", @response.media_type
    assert_includes @response.body, entries(:one).body
  end

  test "new redirects to sign in when not authenticated" do
    get new_entry_url
    assert_redirected_to new_session_url
  end
end
