# frozen_string_literal: true

class BlogController < ApplicationController
  layout "blog"
  disallow_account_scope
  allow_unauthenticated_access

  def index
    @posts = BlogPost.all.sort_by(&:date).reverse
  end

  def show
    @post = BlogPost.find(params[:id])
    head :not_found unless @post
  end
end
