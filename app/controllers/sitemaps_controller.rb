class SitemapsController < ApplicationController
  disallow_account_scope
  allow_unauthenticated_access
  allow_search_engine_indexing
  layout false

  def show
    @posts = BlogPost.all rescue []

    respond_to do |format|
      format.xml
    end
  end
end
