require "test_helper"

class ErrorsControllerTest < ActionDispatch::IntegrationTest
  test "unknown paths render the buildlog not-found page" do
    get "/a-missing-buildlog-page"

    assert_response :not_found
    assert_select "title", "Page not found - buildlog"
    assert_select "h1", "That note is not here."
    assert_select "a[href=?]", entries_path(anchor: "feed"), text: "Read the latest notes"
  end

  test "unknown formatted paths still render the HTML not-found page" do
    get "/a-missing-buildlog-page.json", headers: { "ACCEPT" => "application/json" }

    assert_response :not_found
    assert_equal "text/html", @response.media_type
    assert_select "h1", "That note is not here."
  end

  test "unknown non-GET paths are not routed through the public error controller" do
    post "/a-missing-buildlog-page"

    assert_response :not_found
  end
end
