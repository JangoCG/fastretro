# frozen_string_literal: true

# Custom HTML renderer with Rouge syntax highlighting
class HTMLWithRouge < Redcarpet::Render::HTML
  def block_code(code, language)
    language ||= "text"
    lexer = Rouge::Lexer.find_fancy(language, code) || Rouge::Lexers::PlainText.new
    formatter = Rouge::Formatters::HTML.new
    highlighted = formatter.format(lexer.lex(code))

    %(<pre class="highlight"><code class="language-#{language}">#{highlighted}</code></pre>)
  end
end

MARKDOWN = Redcarpet::Markdown.new(
  HTMLWithRouge.new(with_toc_data: true),
  autolink: true,
  tables: true,
  fenced_code_blocks: true,
  highlight: true,
  strikethrough: true,
  superscript: true,
  no_intra_emphasis: true
)
