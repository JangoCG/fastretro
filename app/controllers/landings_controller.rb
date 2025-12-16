class LandingsController < ApplicationController
  def show
    if Current.account.retros.one?
      redirect_to retro_path(Current.account.retros.first)
    else
      redirect_to root_path
    end
  end
end
