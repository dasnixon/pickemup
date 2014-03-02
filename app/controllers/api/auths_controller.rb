class Api::AuthsController < ApplicationController
  respond_to :json

  def logged_in
    respond_with({company: company_signed_in?, user: user_signed_in?})
  end
end
