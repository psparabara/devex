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
      sign_in @user, "true"
      redirect_to @user
    rescue ActiveRecord::RecordInvalid
      flash.now[:danger] = I18n.translate('register.fail')
      render :new
    end
  end
  
  def request_token
  end

	def send_password_token
		if(user = User.find_by_email(params[:email]))
			@link = newpass_user_url(user.auth_token)
			respond_to do |format|
				UserMailer.password_reset_url_email(user, @link).deliver				
				format.html
			end
		else
			flash.now[:danger] = I18n.translate('register.fail')
			render :fail
		end
	end

	def new_password
		if (@user = User.find_by_auth_token(params[:id]))
			@token = params[:id]
			respond_to do |format|
				format.html
			end
		else
			flash.now[:danger] = I18n.translate('password_reset.token_not_valid')
			render :fail
		end
	end

	def reset_password
		if(@user = User.find_by_auth_token(params[:token])) 
			@user.password = params[:user][:password]
			@user.password_confirmation = params[:user][:password_confirmation]
			if @user.save
				flash[:success] = I18n.translate('password_reset.success')
				redirect_to root_url
			else
				flash.now[:danger] = I18n.translate('password_reset.fail')
				render :fail
			end
		else
			flash.now[:danger] = I18n.translate('password_reset.token_not_valid')
			render :fail
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
