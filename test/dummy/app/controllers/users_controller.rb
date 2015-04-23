class UsersController < ApplicationController
  cache_sweeper RefererTracking::Sweeper

  # GET /users
  # GET /users.json
  def index
    referer_tracking_add_info('session_added', 'testing_session_add')
    referer_tracking_add_info('session_added_hash', 'testing_session_add_without_db_column')
    @users = User.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @users }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    referer_tracking_add_info("show_action", "CUSTOM_VAL")
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @user }
    end
  end

  # GET /users/new
  # GET /users/new.json
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.json
  def create
    referer_tracking_request_set_info('request_added', 'testing_request_add')
    referer_tracking_request_set_info('request_added_hash', 'testing_request_add_without_db_column')
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, :notice => 'User was successfully created.' }
        format.json { render :json => @user, :status => :created, :location => @user }
      else
        format.html { render :action => "new" }
        format.json { render :json => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  def create_with_custom_saving
    @user = User.new(params[:user])
    @user.save
    referer_tracking_after_create(@user)
    render 'index'
  end
  def build_without_saving
    @user = User.new(params[:user])
    referer_tracking_after_create(@user)
    render 'index'
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to @user, :notice => 'User was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :ok }
    end
  end
end
