class Entry < ApplicationRecord
  validates :body, presence: true
  validates :link, format: { with: %r{\Ahttps?://}i }, allow_blank: true

  default_scope { order(created_at: :desc) }
end
