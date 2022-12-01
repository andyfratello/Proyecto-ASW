class CommentsController < ApplicationController
  before_action :set_comment, only: %i[ show edit update destroy like unlike]

  # GET /comments or /comments.json
  def index
    @comments = Comment.all
    micropost = params[:micropost]
    user = params[:user]

    if micropost != nil && user != nil
      render :json => { "status" => "400", "error" => "Do not fill both fields at the same time." }, status: :bad_request
    elsif micropost != nil
      if Micropost.where(id: micropost).exists?
          @comments = Comment.where(micropost_id: micropost).order(created_at: :desc)
      else
        render :json => { "status" => "404", "error" => "This micropost does not exist." }, status: :not_found and return
      end
    elsif user != nil
      if User.where(id: user).exists?
        @comments = Comment.where(user_id: user).order(created_at: :desc)
      else
        render :json => { "status" => "404", "error" => "This user does not exist." }, status: :not_found and return
      end
    end
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
    api_key = request.headers[:HTTP_X_API_KEY]
    if api_key.nil?
      render :json => { "status" => "401", "error" => "No Api key provided." }, status: :unauthorized and return
    else
      @APIuser = User.find_by_api_key(api_key)
      current_user = @APIuser
      if @APIuser.nil?
        render :json => { "status" => "401", "error" => "No User found with the Api key provided." }, status: :unauthorized and return
      end
    end

    @micropost = Micropost.find(params[:micropost_id])
    @comment = @micropost.comments.new(comment_params)
    if current_user != nil
      @comment.user_id = current_user.id
    end

    respond_to do |format|
      if @comment.text != "" && @comment.save
        format.html { redirect_to  micropost_path(@micropost) }
        format.json { render :show, status: :created, location: micropost_path(@comment.micropost_id) }
      else
        format.json { render json: @micropost.errors, status: :unprocessable_entity }
      end
    end

  end

  # PATCH/PUT /comments/1 or /comments/1.json
  def update
    api_key = request.headers[:HTTP_X_API_KEY]
    if api_key.nil?
      render :json => { "status" => "401", "error" => "No Api key provided." }, status: :unauthorized and return
    else
      @APIuser = User.find_by_api_key(api_key)
      if @APIuser.nil?
        render :json => { "status" => "401", "error" => "No User found with the Api key provided." }, status: :unauthorized and return
      elsif @comment.user_id != @APIuser.id
        render :json => { "status" => "401", "error" => "Only the creator of the comment can edit it." }, status: :unauthorized and return
      end
    end
    respond_to do |format|
      if @comment.update(comment_params)
        format.html { redirect_to micropost_path(@comment.micropost_id)}
        format.json { render :show, status: :ok, location: micropost_path(@comment.micropost_id) }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /comments/1 or /comments/1.json
  def destroy
    api_key = request.headers[:HTTP_X_API_KEY]
    if api_key.nil?
      render :json => { "status" => "401", "error" => "No Api key provided." }, status: :unauthorized and return
    else
      @APIuser = User.find_by_api_key(api_key)
      if @APIuser.nil?
        render :json => { "status" => "401", "error" => "No User found with the Api key provided." }, status: :unauthorized and return
      elsif @comment.user_id != @APIuser.id
        render :json => { "status" => "401", "error" => "Only the creator of the comment can delete it." }, status: :unauthorized and return
      end
    end
    @comments = Comment.where(parent_id: @comment.id)
    @comments.each do |comment|
      comment.destroy
    end
    if @comment.destroy
    respond_to do |format|
      format.html { redirect_to user_comments_url }
      format.json { render :json => { "status" => "202", "Accepted" => "The comment has been deleted successfully." }, status: 202 and return }
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
      if current_user != nil
        params.require(:comment).permit(:text, :user_id, :micropost_id, :parent_id)
      else
        params.permit(:text, :user_id, :micropost_id, :parent_id)
      end
    end
end
