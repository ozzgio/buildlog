class PasswordsController < ApplicationController
  PASSWORD_RESET_TOKEN_MAX_LENGTH = 512

  allow_unauthenticated_access
  before_action :set_user_by_token, only: %i[ edit update ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_password_path, alert: "Try again later." }

  def new
  end

  def create
    if (email_address = bounded_email_address) && (user = User.find_by(email_address: email_address))
      PasswordsMailer.reset(user).deliver_later
    end

    redirect_to new_session_path, notice: "Password reset instructions sent (if user with that email address exists)."
  end

  def edit
  end

  def update
    if password_params && @user.update(password_params)
      @user.sessions.destroy_all
      redirect_to new_session_path, notice: "Password has been reset."
    else
      redirect_to edit_password_path(params[:token]), alert: "Passwords did not match."
    end
    end

  private
    def set_user_by_token
      if password_reset_token.length > PASSWORD_RESET_TOKEN_MAX_LENGTH
        redirect_to new_password_path, alert: "Password reset link is invalid or has expired."
        return
      end

      @user = User.find_by_password_reset_token!(password_reset_token)
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      redirect_to new_password_path, alert: "Password reset link is invalid or has expired."
    end

    def bounded_email_address
      email_address = params[:email_address].to_s
      return if email_address.length > User::EMAIL_MAX_LENGTH

      email_address
    end

    def password_params
      password = params[:password].to_s
      password_confirmation = params[:password_confirmation].to_s
      return if password.length > User::PASSWORD_MAX_LENGTH
      return if password_confirmation.length > User::PASSWORD_MAX_LENGTH

      params.permit(:password, :password_confirmation)
    end

    def password_reset_token
      params[:token].to_s
    end
end
