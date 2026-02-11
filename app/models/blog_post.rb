# frozen_string_literal: true

class BlogPost
  POSTS_PATH = Rails.root.join("app", "views", "blog", "posts")

  attr_reader :slug, :title, :date, :author, :description, :image, :content

  def initialize(slug:, title:, date:, author:, description:, image:, content:)
    @slug = slug
    @title = title
    @date = date
    @author = author
    @description = description
    @image = image
    @content = content
  end

  def self.all
    Rails.cache.fetch(cache_key_for_posts, expires_in: 12.hours) do
      post_files.filter_map { |file| parse_file(file) }.sort_by(&:date).reverse
    end
  end

  def self.find(slug)
    all.find { |post| post.slug == slug.to_s }
  end

  def self.parse_file(file)
    content = File.read(file)
    slug = File.basename(file, ".md")

    frontmatter, body = extract_frontmatter(content)
    return nil unless frontmatter

    new(
      slug: slug,
      title: frontmatter["title"] || slug.titleize,
      date: parse_date(frontmatter["date"]),
      author: frontmatter["author"] || "FastRetro Team",
      description: frontmatter["description"] || "",
      image: frontmatter["image"],
      content: MARKDOWN.render(body).html_safe
    )
  end

  def self.extract_frontmatter(content)
    if content.start_with?("---")
      parts = content.split("---", 3)
      if parts.length >= 3
        frontmatter = YAML.safe_load(parts[1], permitted_classes: [ Date, Time ])
        body = parts[2].strip
        return [ frontmatter, body ]
      end
    end
    [ {}, content ]
  end

  def self.parse_date(date_value)
    case date_value
    when Date, Time
      date_value.to_date
    when String
      Date.parse(date_value)
    else
      Date.today
    end
  end

  def self.post_files
    Dir.glob(POSTS_PATH.join("*.md"))
  end

  def self.cache_key_for_posts
    files = post_files
    latest_mtime = files.max_by { |file| File.mtime(file) }&.then { |file| File.mtime(file).to_i } || 0
    "blog_posts:v1:#{files.size}:#{latest_mtime}"
  end

  def read_time
    words = content.gsub(/<[^>]*>/, "").split.size
    minutes = (words / 200.0).ceil
    "#{minutes} min read"
  end

  def formatted_date
    date.strftime("%d.%m.%Y")
  end
end
