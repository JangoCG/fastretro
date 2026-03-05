module ApplicationHelper
  def page_title_tag
    account_name = if Current.account && Current.session&.identity&.users&.many?
      Current.account&.name
    end
    tag.title [ @page_title, account_name, "FastRetro" ].compact.join(" | ")
  end

  def analytics_tag
    return unless Rails.env.production? || ENV["ANALYTICS"] == "true"

    tag.script(defer: true, src: "https://analytics.cengizg.com/script.js", "data-website-id": "610f328e-d047-4aeb-9570-2535bd072670", nonce: content_security_policy_nonce)
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
