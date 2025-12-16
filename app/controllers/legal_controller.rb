# frozen_string_literal: true

class LegalController < ApplicationController
  layout "legal"
  disallow_account_scope
  allow_unauthenticated_access

  def imprint
    @content = render_markdown("imprint.md")
  end

  def privacy_policy
    @content = render_markdown("privacy_policy.md")
  end

  private

  def render_markdown(filename)
    md_path = Rails.root.join("app", "views", "markdown", filename)
    MARKDOWN.render(File.read(md_path)).html_safe
  end
end
