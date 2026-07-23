require "test_helper"

class EntryTest < ActiveSupport::TestCase
  test "body has a server-side length cap" do
    entry = Entry.new(body: "a" * (Entry::BODY_MAX_LENGTH + 1))

    assert_not entry.valid?
    assert_includes entry.errors[:body], "is too long (maximum is #{Entry::BODY_MAX_LENGTH} characters)"
  end

  test "link has a server-side length cap" do
    entry = Entry.new(body: "bounded", link: "https://example.com/#{"a" * Entry::LINK_MAX_LENGTH}")

    assert_not entry.valid?
    assert_includes entry.errors[:link], "is too long (maximum is #{Entry::LINK_MAX_LENGTH} characters)"
  end

  test "public feed scope is bounded" do
    Entry.delete_all
    (Entry::FEED_LIMIT + 1).times { |index| Entry.create!(body: "entry #{index}") }

    assert_equal Entry::FEED_LIMIT, Entry.public_feed.size
  end
end
