class User < ApplicationRecord
  EMAIL_MAX_LENGTH = 254
  PASSWORD_MAX_LENGTH = 72

  has_secure_password
  has_many :sessions, dependent: :destroy

  validates :email_address, presence: true, length: { maximum: EMAIL_MAX_LENGTH }
  validates :password, length: { maximum: PASSWORD_MAX_LENGTH }, allow_nil: true

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
