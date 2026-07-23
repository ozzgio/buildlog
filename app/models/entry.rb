class Entry < ApplicationRecord
  FEED_LIMIT = 50
  BODY_MAX_LENGTH = 2_000
  LINK_MAX_LENGTH = 2_048

  validates :body, presence: true, length: { maximum: BODY_MAX_LENGTH }
  validates :link,
    length: { maximum: LINK_MAX_LENGTH },
    format: { with: %r{\Ahttps?://\S+\z}i },
    allow_blank: true

  default_scope { order(created_at: :desc) }
  scope :public_feed, -> { limit(FEED_LIMIT) }
end
