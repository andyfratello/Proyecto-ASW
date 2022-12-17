class LikesController < ApplicationController
  before_action :find_like, only: [:destroy]

  def create
    @micropost = Micropost.where(id: params[:micropost_id]).first
    if @micropost == nil
      render :json => { "status" => "401", "error" => "Micropost not found." }, status: :not_found and return
    end

    unless current_user.nil?
      unless already_liked_vote?
        @micropost.likes.create(user_id: current_user.id)
        @micropost.likes_count += 1
        @micropost.save
      else
      render :json => { "status" => "400", "error" => "This user has already voted this micropost." }, status: :bad_request and return
      end
    end

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
    if current_user.nil?
      if already_liked_vote?
        render :json => { "status" => "400", "error" => "This user has already voted this micropost." }, status: :bad_request and return
      else
        @micropost.likes.create(user_id: @user.id)
        @micropost.likes_count += 1
        @micropost.save
      end
    end

    redirect_back fallback_location: root_path # redirect_to microposts_path(@micropost)
  end

  def destroy
    @micropost = Micropost.where(id: params[:id]).first
    if @micropost == nil
      render :json => { "status" => "401", "error" => "Micropost not found." }, status: :not_found and return
    end
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

    if already_liked_unvote?
      @like.destroy
      @micropost.likes_count-=1
      @micropost.save

      if current_user != nil
        redirect_back fallback_location: root_path # redirect_to microposts_path(@micropost)
      else
        respond_to do |format|
        format.json { render @micropost, status: :ok, location: @micropost }
        end
      end
    else
      render :json => { "status" => "400", "error" => "Can't unlike a micropost that didn't like before" }, status: :bad_request and return
    end
  end

  def find_like

    @like = Like.where(micropost_id: params[:id]).first
  end

  private
  def already_liked_unvote?
    api_key = request.headers[:HTTP_X_API_KEY]
    @user = User.find_by_api_key(api_key)

    if current_user.nil?
      current_user = @user
    end

    Like.where(user_id: @user.id, micropost_id: params[:id]).exists?
  end

  def already_liked_vote?
    api_key = request.headers[:HTTP_X_API_KEY]
    @user = User.find_by_api_key(api_key)


    Like.where(user_id: @user.id, micropost_id: params[:micropost_id]).exists?
  end

end
