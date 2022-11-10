class LikesController < ApplicationController
  before_action :find_micropost
  before_action :find_like, only: [:destroy]
  def create
    if !(already_liked?)
      @micropost.likes.create(user_id: current_user.id)
    end
    redirect_back fallback_location: root_path # redirect_to microposts_path(@micropost)
  end

  def destroy
    if already_liked?
      @like.destroy
    end
    redirect_back fallback_location: root_path # redirect_to microposts_path(@micropost)
  end

  def find_like
    @like = @micropost.likes.find(params[:id])
  end

  private
  def already_liked?
    Like.where(user_id: current_user.id, micropost_id: params[:micropost_id]).exists?
  end

  def find_micropost
    # @micropost = Micropost.find(params[:micropost_id])
    @micropost = Micropost.find_by(id: params[:micropost_id])
  end
end
