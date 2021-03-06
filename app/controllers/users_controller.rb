class UsersController < ApplicationController
  before_filter :check_signed_in, except: [:new, :create, :request_token,
                :send_password_token, :new_password, :reset_password]

  def new
    @user = User.new
  end

  def show
    @user = User.find(params[:id])
    authorize! :read, @user
  end

  def create
    @user = User.new(user_params)
    begin
      @user.save!
      flash[:success] = I18n.translate('register.success')
      sign_in @user, "false"
      redirect_to @user
    rescue ActiveRecord::RecordInvalid
      flash.now[:danger] = I18n.translate('register.fail')
      render :new
    end
  end
  
  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation)
  end

  def check_signed_in
    unless signed_in?
      flash[:warning] = I18n.translate('authorization.required')
      redirect_to sign_in_path(redirect_url: request.original_url)
    end
  end
end
