class UsersController < ApplicationController
  def edit

  end

  def update

  end

  def resume
    @user = User.find_by_id(params[:id])
    @stackexchange = @user.stackexchange if @user
  end
end
