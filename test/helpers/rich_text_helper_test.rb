require "test_helper"

class RichTextHelperTest < ActionView::TestCase
  test "bare gif links render as inline images" do
    html = link_html("https://media0.giphy.com/media/abc123/giphy.gif")

    output = embed_gif_links(html)

    assert_dom_equal <<~HTML.strip, output
      <p><img src="https://media0.giphy.com/media/abc123/giphy.gif" alt="GIF" title="https://media0.giphy.com/media/abc123/giphy.gif" loading="lazy" referrerpolicy="no-referrer" class="gif-embed"></p>
    HTML
  end

  test "gif urls with query params render as inline images" do
    output = embed_gif_links(link_html("https://media.tenor.com/abc/dance.gif?width=200"))

    assert_match %r{<img[^>]+src="https://media\.tenor\.com/abc/dance\.gif\?width=200"}, output
  end

  test "text links to gifs stay links" do
    html = %(<p><a href="https://example.com/fun.gif">check this out</a></p>)

    assert_equal html, embed_gif_links(html)
  end

  test "non-gif links stay links" do
    html = link_html("https://example.com/page")

    assert_equal html, embed_gif_links(html)
  end

  test "non-https gif links stay links" do
    html = link_html("http://example.com/fun.gif")

    assert_equal html, embed_gif_links(html)
  end

  test "invalid urls stay links" do
    html = link_html("https://exa mple.com/fun.gif")

    assert_equal html, embed_gif_links(html)
  end

  test "opaque https uris without a host stay links" do
    html = link_html("https:foo.gif")

    assert_equal html, embed_gif_links(html)
  end

  test "https urls with a gif host but no gif path stay links" do
    html = link_html("https://foo.gif")

    assert_equal html, embed_gif_links(html)
  end

  test "javascript scheme gif links stay links" do
    html = link_html("javascript:alert(1)//fun.gif")

    assert_equal html, embed_gif_links(html)
  end

  test "data uri gif links stay links" do
    html = link_html("data:image/gif;base64,R0lGOD//fun.gif")

    assert_equal html, embed_gif_links(html)
  end

  test "uppercase gif extension renders as inline image" do
    assert_match %r{<img[^>]+class="gif-embed"}, embed_gif_links(link_html("https://example.com/fun.GIF"))
  end

  test "multiple gif links all render as inline images" do
    html = link_html("https://example.com/a.gif") + link_html("https://example.com/b.gif")

    assert_equal 2, embed_gif_links(html).scan("<img").size
  end

  test "unparseable html passes through untouched" do
    html = "<div>" * 450 + "https://example.com/fun.gif"

    assert_equal html, embed_gif_links(html)
  end

  test "blank input passes through untouched" do
    assert_equal "", embed_gif_links(nil).to_s
    assert_equal "<p>no links here</p>", embed_gif_links("<p>no links here</p>")
  end

  test "rendered rich text embeds bare gif links through the content layout" do
    feedback = feedbacks(:one)
    feedback.update!(content: '<p><a href="https://example.com/fun.gif">https://example.com/fun.gif</a></p>')

    html = feedback.content.to_s

    assert_match %r{<img[^>]+class="gif-embed"}, html
  end

  private
    def link_html(url)
      %(<p><a href="#{url}">#{url}</a></p>)
    end
end
