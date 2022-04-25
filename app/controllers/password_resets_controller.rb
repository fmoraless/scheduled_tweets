class PasswordResetsController < ApplicationController
  def new
  end

  def create
    @user = User.find_by(email: params[:email])

      # si encontramos un usuario
      if @user.present?
          #send an email
        PasswordMailer.with(user: @user).reset.deliver_now
      end
      redirect_to root_path, notice: "If an account with that email was found, we have sent a link"
  end

  def edit
    @user = User.find_signed(params[:token], purpose: "password_reset")
    #binding.irb
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    redirect_to sign_in_path, alert: "YOur token has expires, please try again"
  end

  def update
    @user = User.find_signed(params[:token], purpose: "password_reset")
    if @user.update(password_params)
      redirect_to sign_in_path, notice: "Your password was reset successfully. please sign in"
    else
      render :edit
    end
  end

  private

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end