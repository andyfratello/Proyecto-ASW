class MicropostsController < ApplicationController
  before_action :set_micropost, only: %i[ show edit update destroy like unlike]

  # GET /microposts or /microposts.json
  def index
    # api_key = request.headers[:HTTP_X_API_KEY]
    @microposts = Micropost.all

    sort = params[:sort]
    type = params[:type]
    user = params[:user]

    if sort == 'date'
      @microposts = Micropost.order(created_at: :desc)
    elsif sort == 'likes'
      @microposts = Micropost
    elsif type == 'ask'
      @microposts = Micropost.where(url: [nil, ""])

      #  if api_key.nil?
      # render :json => { "status" => "401", "error" => "No Api key provided." }, status: :unauthorized
      #else
      # @user = User.find_by_api_key(api_key)
      # if @user.nil?
      #   render :json => { "status" => "401", "error" => "No User found with the Api key provided." }, status: :unauthorized
      # elsif user != nil
      #   @microposts = Micropost.where(user_id: user).order(created_at: :desc)
      # end

      # end

    end
  end

  # GET /microposts/1 or /microposts/1.json
  def show
    @micropost = Micropost.find(params[:id])
    @comments = Comment.where(micropost_id: @micropost.id)
  end

  # GET /microposts/new
  def new
    @micropost = Micropost.new
  end

  # GET /microposts/1/edit
  def edit
  end

  # POST /microposts or /microposts.json
  def create
    @micropost = Micropost.new(micropost_params)
    @micropost.user_id = current_user.id

    respond_to do |format|
      if micropost_params[:url] != "" && Micropost.exists?(url: micropost_params[:url])
        @micropost = Micropost.find_by(url: micropost_params[:url])
        format.html { redirect_to @micropost }
        # CAMBIAR ^ para que redireccione a la vista
        format.json { render json: @micropost.errors, status: :unprocessable_entity }
      end

      if micropost_params[:url] != "" && micropost_params[:text] != ""
        @comment = Comment.new
        @comment.text = @micropost.text
        @comment.micropost = @micropost
        @comment.user = current_user
        @micropost.text = ""
        if @micropost.save && @comment.save
          format.html { redirect_to microposts_url(:sort => "date") }
          format.json { render :show, status: :created, location: @micropost }
        end
      end
      if @micropost.save
        format.html { redirect_to microposts_url(:sort => "date") }
        format.json { render :show, status: :created, location: @micropost }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @micropost.errors, status: :unprocessable_entity }
      end
    end

  end

  # PATCH/PUT /microposts/1 or /microposts/1.json
  def update
    respond_to do |format|
      if @micropost.update(micropost_params)
        format.html { redirect_to micropost_url(@micropost) }
        format.json { render :show, status: :ok, location: @micropost }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @micropost.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /microposts/1 or /microposts/1.json
  def destroy
    @micropost.destroy

    respond_to do |format|
      format.html { redirect_to microposts_url }
      format.json { head :no_content }
    end
  end

  def like
    @micropost.save
    respond_to do |format|
      format.html { redirect_to root_path }
      format.json { head :no_content }
    end
  end

  def unlike
    @micropost.save
    respond_to do |format|
      format.html { redirect_to root_path }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_micropost
    @micropost = Micropost.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def micropost_params
    params.require(:micropost).permit(:title, :url, :text, :user_id)
  end
end
