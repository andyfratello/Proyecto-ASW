class LikesController < ApplicationController
  before_action :find_micropost
  before_action :find_like, only: [:destroy]
  def create
    api_key = request.headers[:HTTP_X_API_KEY]
    if api_key.nil?
      render :json => { "status" => "401", "error" => "No Api key provided." }, status: :unauthorized and return
    else
      @user = User.find_by_api_key(api_key)
      if @user.nil?
        render :json => { "status" => "401", "error" => "No User found with the Api key provided." }, status: :unauthorized and return
      elsif @micropost.user_id == @user.id
        render :json => { "status" => "401", "error" => "The creator of the micropost can't like it." }, status: :unauthorized and return
      end
    end
    if current_user == nil
      current_user = @user
    end

    if !(already_liked?)
      @micropost.likes.create(user_id: current_user.id)
      @micropost.likes_count+=1
      @micropost.save
    end


    redirect_back fallback_location: root_path # redirect_to microposts_path(@micropost)
  end

  def destroy
    api_key = request.headers[:HTTP_X_API_KEY]
    if api_key.nil?
      render :json => { "status" => "401", "error" => "No Api key provided." }, status: :unauthorized and return
    else
      @user = User.find_by_api_key(api_key)
      if @user.nil?
        render :json => { "status" => "401", "error" => "No User found with the Api key provided." }, status: :unauthorized and return
      elsif @micropost.user_id == @user.id
        render :json => { "status" => "401", "error" => "The creator of the micropost can't unlike it." }, status: :unauthorized and return
      end
    end

    if already_liked?
      @like.destroy
      @micropost.likes_count-=1
      @micropost.save
    end
    redirect_back fallback_location: root_path # redirect_to microposts_path(@micropost)
  end

  def find_like
    @like = @micropost.likes.find(params[:id])
  end

  private
  def already_liked?
    api_key = request.headers[:HTTP_X_API_KEY]
      @user = User.find_by_api_key(api_key)

    if current_user == nil
      current_user = @user
    end

    Like.where(user_id: current_user.id, micropost_id: params[:micropost_id]).exists?
  end

  def find_micropost
    # @micropost = Micropost.find(params[:micropost_id])
    @micropost = Micropost.find_by_id(id: params[:micropost_id])
    if @micropost == nil
      render :json => { "status" => "401", "error" => "Micropost not found." }, status: :unauthorized and return
    end
  end
end
