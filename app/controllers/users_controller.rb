class UsersController < ApplicationController
  before_action :set_user, only: %i[ show edit update destroy ]
  # GET /users or /users.json
  def index
    @users = User.all
  end
  # GET /users/1 or /users/1.json
  def show
    @user = User.find_by_id(params[:id])
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
    api_key = request.headers[:HTTP_X_API_KEY]
    if api_key.nil?
      render :json => { "status" => "401", "error" => "No Api key provided." }, status: :unauthorized and return
    else
      @APIuser = User.find_by_api_key(api_key)
      if @APIuser.nil?
        render :json => { "status" => "401", "error" => "No User found with the Api key provided." }, status: :unauthorized and return
      elsif @APIuser.id != @user.id
        render :json => { "status" => "401", "error" => "Only the user can edit his biography." }, status: :unauthorized and return
      end
    end
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
    api_key = request.headers[:HTTP_X_API_KEY]
    if api_key.nil?
      if current_user
        @likes = Like.where(user_id: current_user.id)
      else
        render :json => { "status" => "401", "error" => "No Api key provided." }, status: :unauthorized and return
      end
    else
      @user = User.find_by_api_key(api_key)
      if @user.id.to_s === params[:id].to_s
        @likes = Like.where(user_id: @user.id)
        @likes.each do |like|
          print(like.micropost_id, " ")
        end
      else
        render :json => { "status" => "401", "error" => "Only the owner can view its liked microposts." }, status: :unauthorized and return
      end
    end
    @likes.each do |like|
      print(like.micropost_id, " ")
      @microposts = Micropost.where(id: like.micropost_id)
    end
    respond_to do |format|
      format.html { render :user_submissions}
      format.json { render :json => @microposts, status: :created }
    end
  end
  def upvoted_comments
    api_key = request.headers[:HTTP_X_API_KEY]
    if current_user.nil?
      if api_key.nil?
        render :json => { "status" => "401", "error" => "No Api key provided." }, status: :unauthorized and return
      else
        @user = User.find_by_api_key(api_key)
        if @user.nil?
          render :json => { "status" => "401", "error" => "No User found with the Api key provided." }, status: :unauthorized and return
        elsif params[:id].to_s != @user.id.to_s
          render :json => { "status" => "401", "error" => "Only the owner can view its liked comments." }, status: :unauthorized and return
        end
      end
    else
      @user = current_user
    end

    @comment_likes = CommentLike.where(user_id: @user.id)
    @comment_likes.each do |like|
      print(like.id)
    end
    respond_to do |format|
      format.html { render :user_upvoted_comments}
      format.json { render :json => @comment_likes, status: :created }
    end
  end
  def comments
    @user = User.find(params[:id])
    @comments = Comment.where(user_id: @user.id).order(likes_count: :desc)
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
    elsif User.where(id: params[:id]).exists?
      @user = User.find(params[:id])
    else
      render :json => { "status" => "404", "error" => "The user with the id provided doesn't exist" }, status: :not_found and return
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