module ApplicationHelper
  def page_title_tag
    account_name = if Current.account && Current.session&.identity&.users&.many?
      Current.account&.name
    end
    tag.title [ @page_title, account_name, "FastRetro" ].compact.join(" | ")
  end

  # Simple Analytics - privacy-first analytics.
  # Only renders in production (or when SIMPLE_ANALYTICS=true is set).
  #
  # @see https://docs.simpleanalytics.com/script
  def simple_analytics_tag
    return unless Rails.env.production? || ENV["SIMPLE_ANALYTICS"] == "true"

    tag.script(async: true, src: "https://scripts.simpleanalyticscdn.com/latest.js", "data-collect-dnt": "true", nonce: content_security_policy_nonce)
  end

  def icon_tag(name, **options)
    tag.span class: class_names("icon icon--#{name}", options.delete(:class)), "aria-hidden": true, **options
  end

  def inline_svg(name)
    file_path = "#{Rails.root}/app/assets/images/#{name}.svg"
    return File.read(file_path).html_safe if File.exist?(file_path)
    "(not found)"
  end
end
