class Session < ApplicationRecord
  USER_AGENT_MAX_LENGTH = 255
  IP_ADDRESS_MAX_LENGTH = 45

  belongs_to :user

  validates :user_agent, length: { maximum: USER_AGENT_MAX_LENGTH }, allow_nil: true
  validates :ip_address, length: { maximum: IP_ADDRESS_MAX_LENGTH }, allow_nil: true
end
