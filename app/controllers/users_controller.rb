class UsersController < ApplicationController
  before_filter :eager_load_user, :check_permissions, only: [:resume]
  before_filter :get_and_check_user, only: [:edit, :update, :preferences, :get_preference, :update_preference, :listings]
  before_filter :cleanup_preference_params, only: [:update_preference]
  respond_to :json, :html

  def edit
    respond_with @user
  end

  def update
    if @user.update(params[:user].merge(manually_setup_profile: true))
      respond_with(@user, location: nil, status: :created)
    else
      render json: { errors: @user.errors }, status: :bad_request
    end
  end

  def resume
    if @user
      @preference        = @user.preference
      @github_account    = @user.github_account
      if @github_account
        @repos           = @github_account.repos
        @orgs            = @github_account.organizations
      end
      @stackexchange     = @user.stackexchange
      @linkedin          = @user.linkedin
      if @linkedin
        @profile         = @linkedin.profile
        @positions       = @profile.positions
        @educations      = @profile.educations
        @skills          = @profile.skills
      end
    end
  end

  def preferences
  end

  def listings
    @job_listings = @user.mailbox.sentbox.collect do |conv|
      listing = JobListing.find(conv.job_listing_id)
      company = listing.company
      OpenStruct.new(listing: listing, company: company, conversation: conv)
    end
  end

  def get_preference
    preference = @user.preference
    preference.get_preference_defaults
    respond_with preference
  end

  def update_preference
    preference = @user.preference
    if preference.update(@bathed_preferences)
      respond_with preference
    else
      render json: { errors: preference.errors }, status: :bad_request
    end
  end

  private

  def eager_load_user
    @user = User.includes(
      stackexchange: [],
      preference: [],
      github_account: [:repos, :organizations],
      linkedin: {profile: [:positions, :educations]}
    ).find(params[:id]) #eager load all user information
  end

  def cleanup_preference_params
    @bathed_preferences = Preference.cleanup_invalid_data(params[:preference])
  end

  def check_permissions
    unless (user_signed_in? && current_user == @user) || company_signed_in?
      redirect_to root_path, notice: 'You don\'t have permissions to view that page.'
    end
  end
end
