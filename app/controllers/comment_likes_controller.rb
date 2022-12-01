class CommentLikesController < ApplicationController
  before_action :find_comment_like, only: [:destroy]

  # POST /comment_likes or /comment_likes.json
  def create
    @comment = Comment.where(id: params[:id]).first
    if @comment == nil
      render :json => { "status" => "401", "error" => "Comment not found." }, status: :not_found and return
    end
    api_key = request.headers[:HTTP_X_API_KEY]
    if api_key.nil?
      render :json => { "status" => "401", "error" => "No Api key provided." }, status: :unauthorized and return
    else
      @APIuser = User.find_by_api_key(api_key)
      if @APIuser.nil?
        render :json => { "status" => "401", "error" => "No User found with the Api key provided." }, status: :unauthorized and return
      elsif @comment.user_id == @APIuser.id
        render :json => { "status" => "401", "error" => "The creator of the comment can't like it." }, status: :unauthorized and return
      end
    end
    if already_liked_vote?
      render :json => { "status" => "401", "error" => "Can't like the same comment." }, status: :unauthorized and return
    else
      if current_user.nil?
        current_user = @APIuser
      end
      @comment.comment_likes.create(user_id: current_user.id)
      @comment.likes_count+=1
      @comment.save
      redirect_back fallback_location: root_path # redirect_to microposts_path(@micropost)
    end
  end

  # DELETE /comment_likes/1 or /comment_likes/1.json
  def destroy
    @comment = Comment.where(id: params[:id]).first
    if already_liked_unvote?
      @comment.likes_count-=1
      @comment_like.destroy
      if current_user != nil
        redirect_back fallback_location: root_path # redirect_to microposts_path(@micropost)
      else
        respond_to do |format|
          format.json { render @comment, status: :ok, location: @comment}
        end
      end
    else
      render :json => { "status" => "400", "error" => "Can't unlike a comment that didn't like before" }, status: :bad_request
    end
  end

  def find_comment_like
    @comment_like = CommentLike.where(comment_id: params[:id]).first
  end

  private
    def already_liked_vote?
      api_key = request.headers[:HTTP_X_API_KEY]
      @user = User.find_by_api_key(api_key)

      CommentLike.where(user_id: @user.id, comment_id: params[:comment_id]).exists?
    end
    # Use callbacks to share common setup or constraints between actions.

  def already_liked_unvote?
    api_key = request.headers[:HTTP_X_API_KEY]
    @user = User.find_by_api_key(api_key)

    CommentLike.where(user_id: @user.id, comment_id: params[:id]).exists?
  end
    def find_comment
      @comment = Comment.find_by(id: params[:comment_id])
    end

end
