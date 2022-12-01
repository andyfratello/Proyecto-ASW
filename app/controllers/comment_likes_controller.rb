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
    if already_liked_vote?(@comment.id)
      render :json => { "status" => "401", "error" => "Can't like the same comment." }, status: :unauthorized
    else
      if current_user.nil?
        current_user = @APIuser
      end
      @comment.comment_likes.create(user_id: current_user.id)
      @comment.likes_count+=1
      @comment.save
      respond_to do |format|
        format.json { render :json => { "status" => "202", "Accepted" => "The comment has been voted successfully." }, status: 202 and return }
      end
    end
  end

  # DELETE /comment_likes/1 or /comment_likes/1.json
  def destroy
    @comment = Comment.where(id: params[:id]).first
    if @comment == nil
      render :json => { "status" => "404", "error" => "Comment not found." }, status: :not_found and return
    end
    api_key = request.headers[:HTTP_X_API_KEY]
    if api_key.nil?
      render :json => { "status" => "401", "error" => "No Api key provided." }, status: :unauthorized and return
    else
      @APIuser = User.find_by_api_key(api_key)
      if @APIuser.nil?
        render :json => { "status" => "401", "error" => "No User found with the Api key provided." }, status: :unauthorized and return
      elsif @comment.user_id == @APIuser.id
        render :json => { "status" => "401", "error" => "The creator of the comment can't unlike it." }, status: :unauthorized and return
      end
    end
    if already_liked_unvote?(@comment.id)
      @comment.likes_count-=1
      @comment_like.destroy
      @comment.save
      respond_to do |format|
        format.json { render :json => { "status" => "202", "Accepted" => "The comment has been unvoted successfully." }, status: 202 and return }
      end
      if current_user != nil
        redirect_back fallback_location: root_path # redirect_to microposts_path(@micropost)
      end
    else
      render :json => { "status" => "400", "error" => "Can't unlike a comment that didn't like before o already had unliked" }, status: :bad_request
    end
  end

  def find_comment_like
    @comment_like = CommentLike.where(comment_id: params[:id]).first
  end

  private
    def already_liked_vote?(id)
      api_key = request.headers[:HTTP_X_API_KEY]
      @user = User.find_by_api_key(api_key)

      CommentLike.where(user_id: @user.id, comment_id: id).exists?
    end
    # Use callbacks to share common setup or constraints between actions.

  def already_liked_unvote?(id)
    api_key = request.headers[:HTTP_X_API_KEY]
    @user = User.find_by_api_key(api_key)

    CommentLike.where(user_id: @user.id, comment_id: id).exists?
  end

  def find_comment
    @comment = Comment.find_by(id: params[:comment_id])
  end

end
