class UsersController < ApplicationController
  respond_to :json, only: [:skills]

  def edit

  end

  def update

  end

  def resume
    @user = User.find(params[:id])
    if @user
      @github_account = @user.github_account
      @repos          = @github_account.repos
      @orgs           = @github_account.organizations
      @stackexchange  = @user.stackexchange
      @linkedin       = @user.linkedin
      @profile        = @linkedin.profile
      @positions      = @profile.positions
      @educations     = @profile.educations
    end
  end

  def skills
    user = User.find_by_id(params[:id])
    respond_with Array user.linkedin.profile if user
  end
end
