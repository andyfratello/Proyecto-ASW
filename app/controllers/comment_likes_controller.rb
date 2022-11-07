class CommentLikesController < ApplicationController
  before_action :set_comment_like, only: %i[ show edit update destroy ]
  before_action :find_comment_like, only: [:destroy]

  # GET /comment_likes or /comment_likes.json
  def index
    @comment_likes = CommentLike.all
  end

  # GET /comment_likes/1 or /comment_likes/1.json
  def show
  end

  # GET /comment_likes/new
  def new
    @comment_like = CommentLike.new
  end

  # GET /comment_likes/1/edit
  def edit
  end

  # POST /comment_likes or /comment_likes.json
  def create
    @comment = Comment.find(params[:comment_id])
    @comment_like.user_id = current_user.id
    @comment_like.comment_id = @comment.id
    @comment_like = @comment.comment_likes.create(comment_like_params)
    @comment_like.save
    redirect_back fallback_location: root_path # redirect_to microposts_path(@micropost)
  end

  # DELETE /comment_likes/1 or /comment_likes/1.json
  def destroy
    if !(already_liked?)
      flash[:notice] = "You can't like more than once"
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
    def set_comment_like
      @comment_like = CommentLike.find(params[:id])
    end

    def find_comment
      @comment = Comment.find(params[:comment_id])
    end

    # Only allow a list of trusted parameters through.
    def comment_like_params
      params.require(:comment_like).permit(:comment_id, :user_id)
    end
end
