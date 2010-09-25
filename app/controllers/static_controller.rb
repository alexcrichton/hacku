class StaticController < ApplicationController

  before_filter :require_user

  def graph
  end

end
