class UsersController < ApplicationController
  before_action :set_user, only: %i[ show edit update destroy ]

  # GET /users or /users.json
  def index
    @users = User.all
  end

  # GET /users/1 or /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users or /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to user_url(@user) }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1 or /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to '/users/edit' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1 or /users/1.json
  def destroy
    params[:id] = nil
    redirect_to root_path
=begin
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url, notice: "User was successfully destroyed." }
      format.json { head :no_content }
    end
=end
  end

  def submissions
    @likes = Like.where(user_id: current_user.id)
    # @likes.each do |like|
    # @microposts = Micropost.where(id: like.micropost_id)
    #end
    respond_to do |format|
      format.html { render :user_submissions}
      format.json { head :no_content }
    end
  end

  def upvoted_comments
    @comment_likes = CommentLike.where(user_id: current_user.id)
    # @likes.each do |like|
    # @microposts = Micropost.where(id: like.micropost_id)
    #end
    respond_to do |format|
      format.html { render :user_upvoted_comments}
      format.json { head :no_content }
    end
  end

  def comments
    @user = User.find(params[:id])
    @comments = Comment.where(user_id: @user.id)
    respond_to do |format|
      format.html { render :user_comments}
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      if params[:id] == "sign_out"
        sign_out current_user
      else
        @user = User.find(params[:id])
      end
    end

    # Only allow a list of trusted parameters through.
    def user_params
      if current_user != nil
        params.require(:user).permit(:name, :email, :about)
      else
        params.permit(:name, :email, :about)
      end
    end
end
