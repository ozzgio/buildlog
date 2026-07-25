require "test_helper"

class FeedbackControllerTest < ActionDispatch::IntegrationTest
  test "show renders without authentication and links to GitHub issues" do
    with_buildlog_feedback_url(nil) do
      get feedback_url
    end

    assert_response :success
    assert_select "h1", text: /Tell me/
    assert_select "a[href=?]", "https://github.com/ozzgio/buildlog/issues"
    assert_select "iframe", count: 0
    assert_includes @response.body, "The public form URL is not configured yet."
  end

  test "show embeds the configured feedback form" do
    with_buildlog_feedback_url("https://tally.so/r/example") do
      get feedback_url
    end

    assert_response :success
    assert_select "iframe[src=?][title=?]", "https://tally.so/r/example", "Buildlog feedback form"
    refute_includes @response.body, "The public form URL is not configured yet."
  end

  test "show ignores invalid feedback form urls" do
    with_buildlog_feedback_url("javascript:alert(1)") do
      get feedback_url
    end

    assert_response :success
    assert_select "iframe", count: 0
  end

  private
    def with_buildlog_feedback_url(value)
      original = ENV["BUILDLOG_FEEDBACK_URL"]

      if value.nil?
        ENV.delete("BUILDLOG_FEEDBACK_URL")
      else
        ENV["BUILDLOG_FEEDBACK_URL"] = value
      end

      yield
    ensure
      if original.nil?
        ENV.delete("BUILDLOG_FEEDBACK_URL")
      else
        ENV["BUILDLOG_FEEDBACK_URL"] = original
      end
    end
end
