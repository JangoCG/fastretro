# frozen_string_literal: true

class BlogController < ApplicationController
  layout "blog"
  disallow_account_scope
  allow_unauthenticated_access
  allow_search_engine_indexing

  def index
    @posts = BlogPost.all
  end

  def show
    @post = BlogPost.find(params[:id])
    head :not_found unless @post
  end
end
