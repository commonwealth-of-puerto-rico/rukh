# -*- encoding : utf-8 -*-

class StaticPagesController < ApplicationController
  ## Resource Actions ##
  def home; end

  def help; end

  def dev
    @user = current_user
  end
end
