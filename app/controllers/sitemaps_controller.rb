class SitemapsController < ApplicationController
  disallow_account_scope
  allow_unauthenticated_access
  layout false

  def show
    @posts = BlogPost.all rescue []

    respond_to do |format|
      format.xml
    end
  end
end
