module RichTextHelper
  def rich_text_editor_options(**overrides)
    {
      attachments: true,
      "permitted-attachment-types": ActiveStorage::UploadLimits::CONTENT_TYPES.join(" ")
    }.merge(overrides)
  end

  # Expects already-sanitized HTML (runs after the ActionText sanitizer).
  def embed_gif_links(html)
    return html unless html.to_s.match?(/\.gif/i)

    fragment = Nokogiri::HTML5.fragment(html.to_s)
    gif_links = fragment.css("a[href]").select { |link| bare_gif_link?(link) }

    if gif_links.empty?
      html
    else
      gif_links.each { |link| link.replace(gif_image_for(link)) }
      fragment.to_html.html_safe
    end
  rescue ArgumentError
    html
  end

  private
    def bare_gif_link?(link)
      link.text.strip == link["href"] && gif_url?(link["href"])
    end

    def gif_url?(url)
      uri = URI.parse(url)
      uri.is_a?(URI::HTTPS) && uri.host.present? && File.extname(uri.path.to_s).casecmp?(".gif")
    rescue URI::Error
      false
    end

    def gif_image_for(link)
      link.document.create_element(
        "img",
        src: link["href"],
        alt: "GIF",
        title: link["href"],
        loading: "lazy",
        referrerpolicy: "no-referrer",
        class: "gif-embed"
      )
    end
end
