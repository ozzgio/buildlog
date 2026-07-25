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
    assert_select ".feedback-empty-state"
    assert_includes @response.body, "The public form URL is not configured yet."
  end

  test "show embeds the configured feedback form" do
    with_buildlog_feedback_url("https://tally.so/r/example") do
      get feedback_url
    end

    assert_response :success
    assert_select "iframe[title=?]", "Buildlog feedback form" do |frames|
      src = frames.first["src"]
      assert_equal src, frames.first["data-tally-src"]
      uri = URI.parse(src)
      assert_equal "https", uri.scheme
      assert_equal "tally.so", uri.host
      assert_equal "/embed/example", uri.path
      assert_equal({
        "alignLeft" => "1",
        "hideTitle" => "1",
        "transparentBackground" => "1",
        "dynamicHeight" => "1"
      }, Rack::Utils.parse_nested_query(uri.query))
    end
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
