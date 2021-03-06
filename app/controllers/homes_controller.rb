class HomesController < ApplicationController
  def index
    if signed_in?
      @posts = Post.where(published: true).order('id DESC')
      .page(params[:page])
      render layout: 'admin' if current_user.admin?
      # .reverse
    else
      @posts = Post.where(published: true, pro: false).order('id DESC')
      .page(params[:page])
      # .reverse
    end
  end
end