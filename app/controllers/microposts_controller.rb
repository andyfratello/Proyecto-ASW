class MicropostsController < ApplicationController
  before_action :set_micropost, only: %i[ show edit update destroy like unlike]

  # GET /microposts or /microposts.json
  def index
    # api_key = request.headers[:HTTP_X_API_KEY]
    @microposts = Micropost.order(likes_count: :desc)

    sort = params[:sort]
    type = params[:type]
    user = params[:user]

    if sort == 'date'
      @microposts = Micropost.order(created_at: :desc)
    elsif type == 'ask'
      @microposts = Micropost.where(url: [nil, ""]).order(likes_count: :desc)

      elsif user != nil
        @microposts = Micropost.where(user_id: user).order(likes_count: :desc)

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
    api_key = request.headers[:HTTP_X_API_KEY]
    @micropost = Micropost.new(micropost_params)

    if current_user != nil
      @micropost.user_id = current_user.id
      @micropost.creator_name = current_user.email
    elsif api_key.nil?
      render :json => { "status" => "401", "error" => "No Api key provided." }, status: :unauthorized and return
    else
      @user = User.find_by_api_key(api_key)
      if @user.nil?
        render :json => { "status" => "401", "error" => "No User found with the Api key provided." }, status: :unauthorized and return
      else
        @micropost.user_id = @user.id
        @micropost.creator_name = @user.email
          unless url_valid?(micropost_params[:url])
            render :json => { "status" => "400", "error" => "No valid URL provided" }, status: :bad_request and return

          end
        end
      end

      respond_to do |format|
        if micropost_params[:url] != "" && Micropost.exists?(url: micropost_params[:url])
          @micropost = Micropost.find_by(url: micropost_params[:url])
          format.html { redirect_to @micropost }
          # CAMBIAR ^ para que redireccione a la vista
          format.json { render json: @micropost, status: :ok }
        end

        if micropost_params[:url] != "" && micropost_params[:text] != ""
          @comment = Comment.new
          @comment.text = @micropost.text
          @comment.micropost = @micropost
          @comment.user = @user
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
      api_key = request.headers[:HTTP_X_API_KEY]
      if api_key.nil?
        render :json => { "status" => "401", "error" => "No Api key provided." }, status: :unauthorized and return
      else
        @user = User.find_by_api_key(api_key)
        if @user.nil?
          render :json => { "status" => "401", "error" => "No User found with the Api key provided." }, status: :unauthorized and return
        elsif @micropost.user_id != @user.id
          render :json => { "status" => "401", "error" => "Only the creator of the micropost can edit it." }, status: :unauthorized and return
          unless url_valid?(micropost_params[:url])
            render :json => { "status" => "400", "error" => "No valid URL provided" }, status: :bad_request and return
          end
        end
      end
      if @micropost.url != "" && !params[:text].nil?
        render :json => { "status" => "400", "error" => "Cannot fill the text field of a Micropost with URL" }, status: :bad_request and return
      end
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
      api_key = request.headers[:HTTP_X_API_KEY]
      if api_key.nil?
        render :json => { "status" => "401", "error" => "No Api key provided." }, status: :unauthorized and return
      else
        @user = User.find_by_api_key(api_key)
        if @user.nil?
          render :json => { "status" => "401", "error" => "No User found with the Api key provided." }, status: :unauthorized and return
        elsif @micropost.user_id != @user.id
          render :json => { "status" => "401", "error" => "Only the creator of the micropost can delete it." }, status: :unauthorized and return
        end
      end
      @micropost.destroy

      respond_to do |format|
        format.html { redirect_to microposts_url }
        render :json => { "status" => "204", "error" => "Micropost delete successfully" }, status: :ok and return
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

    def url_valid?(url)
      if url != ""
        url = URI.parse(url) rescue false
      end
      url.kind_of?(URI::HTTP) || url.kind_of?(URI::HTTPS) || url === ""
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_micropost
      if Micropost.exists?(params[:id])
        @micropost = Micropost.find(params[:id])
      elsif @micropost.nil?
        render :json => { "status" => "404", "error" => "No Micropost with the id provided found." }, status: :not_found
      end
    end

    # Only allow a list of trusted parameters through.
    def micropost_params
      if current_user != nil
        params.require(:micropost).permit(:title, :url, :text, :user_id, :creator_name)
      else
        params.permit(:title, :url, :text)
      end
    end

  end
