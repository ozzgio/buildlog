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

  test "public feed is capped" do
    Entry.delete_all
    (Entry::FEED_LIMIT + 1).times do |index|
      Entry.create!(body: "entry #{index}", created_at: index.minutes.ago, updated_at: index.minutes.ago)
    end

    get entries_url

    assert_response :success
    assert_select ".entry-card", Entry::FEED_LIMIT
    refute_includes @response.body, "entry #{Entry::FEED_LIMIT}"
  end

  test "rss feed is capped" do
    Entry.delete_all
    (Entry::FEED_LIMIT + 1).times do |index|
      Entry.create!(body: "rss entry #{index}", created_at: index.minutes.ago, updated_at: index.minutes.ago)
    end

    get feed_url

    assert_response :success
    refute_includes @response.body, "rss entry #{Entry::FEED_LIMIT}"
  end

  test "new redirects to sign in when not authenticated" do
    get new_entry_url
    assert_redirected_to new_session_url
  end

  test "create redirects to sign in when not authenticated" do
    assert_no_difference -> { Entry.count } do
      post entries_url, params: { entry: { body: "private", link: "https://example.com" } }
    end

    assert_redirected_to new_session_url
  end
end
