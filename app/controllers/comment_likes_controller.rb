class CommentLikesController < ApplicationController
  before_action :find_comment
  before_action :find_comment_like, only: [:destroy]

  # POST /comment_likes or /comment_likes.json
  def create
    #if already_liked?
    # flash[:notice] = "You can't like more than once"
    #else
    # @comment = Comment.find_by(params[:comment_id])
    # @comment.comment_likes.create(user_id: current_user.id)
    #end
    @comment.comment_likes.create(user_id: current_user.id)
    redirect_back fallback_location: root_path # redirect_to microposts_path(@micropost)
  end

  # DELETE /comment_likes/1 or /comment_likes/1.json
  def destroy
    if !(already_liked?)
      flash[:notice] = "You can't unlike more than once"
    else
      @comment_like.destroy
    end
    redirect_back fallback_location: root_path # redirect_to microposts_path(@micropost)
  end

  def find_comment_like
    @comment_like = @comment.comment_likes.find(params[:id])
  end

  private
    def already_liked?
      CommentLike.where(user_id: current_user.id, comment_id: params[:comment_id]).exists?
    end
    # Use callbacks to share common setup or constraints between actions.

    def find_comment
      @comment = Comment.find_by(id: params[:comment_id])
    end

end
