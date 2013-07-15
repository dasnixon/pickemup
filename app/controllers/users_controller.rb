class UsersController < ApplicationController
  before_filter :find_user, except: [:resume]
  before_filter :eager_load_user, only: [:resume]
  before_filter :check_invalid_permissions, only: [:preferences, :get_preference, :update_preference]
  respond_to :json, :html

  def resume
    if @user
      @github_account = @user.github_account
      @repos          = @github_account.repos
      @orgs           = @github_account.organizations
      @stackexchange  = @user.stackexchange
      @linkedin       = @user.linkedin
      if @linkedin
        @profile      = @linkedin.profile
        @positions    = @profile.positions
        @educations   = @profile.educations
      end
    end
  end

  def skills
    respond_with Array @user.linkedin.profile if @user
  end

  def preferences
  end

  def get_preference
    respond_with @user.try(:preference)
  end

  def update_preference
    preference = @user.preference
    preference.update_attributes(preference_params)
    respond_with(preference)
  end

  private

  def eager_load_user
    @user ||= User.includes(
      stackexchange: [],
      github_account: [:repos, :organizations],
      linkedin: {profile: [:positions, :educations]}
    ).find(params[:id]) #eager load all user information
  end

  def find_user
    @user ||= User.find(params[:id])
  end

  def preference_params
    params.require(:preference).permit(:expected_salary, :vacation_days,
      :healthcare, :equity, :bonuses, :retirement, :perks, :practices,
      :fulltime, :remote, :potential_availability, :open_source, :company_size,
      :skills, :locations, :industries, :positions, :settings, :dress_codes,
      :company_types)
  end
end
