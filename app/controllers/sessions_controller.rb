class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_path, alert: "Try again later." }

  def new
  end

  def create
    if credential_params && (user = User.authenticate_by(credential_params))
      start_new_session_for user
      redirect_to after_authentication_url
    else
      redirect_to new_session_path, alert: "Try another email address or password."
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path, status: :see_other
  end

  private
    def credential_params
      email_address = params[:email_address].to_s
      password = params[:password].to_s
      return if email_address.length > User::EMAIL_MAX_LENGTH
      return if password.length > User::PASSWORD_MAX_LENGTH

      params.permit(:email_address, :password)
    end
end
