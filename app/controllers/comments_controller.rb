class CommentsController < ApplicationController
  before_action :set_comment, only: %i[ show edit update destroy like unlike]

  # GET /comments or /comments.json
  def index
    @comments = Comment.all
  end

  # GET /comments/1 or /comments/1.json
  def show
    @comment = Comment.find(params[:id])
  end

  # GET /comments/new
  def new
    @comment = Comment.new
  end

  # GET /comments/1/edit
  def edit
  end

  # POST /comments or /comments.json
  def create
    @micropost = Micropost.find(params[:micropost_id])
    @comment = @micropost.comments.new(comment_params)
    @comment.user_id = current_user.id

    respond_to do |format|
      if @comment.text != "" && @comment.save
        format.html { redirect_to  micropost_path(@micropost) }
      else
        format.json { render json: @micropost.errors, status: :unprocessable_entity }
      end
    end

  end

  # PATCH/PUT /comments/1 or /comments/1.json
  def update
    respond_to do |format|
      if @comment.update(comment_params)
        format.html { redirect_to micropost_path(@comment.micropost_id), notice: "Comment was successfully updated." }
        format.json { render :show, status: :ok, location: micropost_path(@comment.micropost_id) }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /comments/1 or /comments/1.json
  def destroy
    if @comment.destroy
    respond_to do |format|
      format.html { redirect_to user_comments_url }
      format.json { head :no_content }
    end
    end
  end

  def comment_like
    @comment.save
    respond_to do |format|
      format.html { redirect_to root_path }
      format.json { head :no_content }
    end
  end

  def comment_unlike
    @comment.save
    respond_to do |format|
      format.html { redirect_to root_path }
      format.json { head :no_content }
    end
  end

  def reply
    @comment = Comment.find(params[:id])
    @micropost = @comment.micropost_id
    respond_to do |format|
      format.html { render :showForm}
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_comment
      @comment = Comment.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def comment_params
      params.require(:comment).permit(:text, :user_id, :micropost_id, :parent_id)
    end
end
