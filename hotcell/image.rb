require "digest"
require "yaml"

module HotcellImage
  def self.tag
    files = %w[ Dockerfile Gemfile Gemfile.lock config.rb ] + Dir.glob("operations/*.rb", base: __dir__).sort
    digest = Digest::SHA256.new

    files.each do |file|
      digest.update(File.binread(File.join(__dir__, file)))
    end

    "#{ENV.fetch("HOTCELL_IMAGE_REPOSITORY", "localhost:5555/fastretro-hotcell")}:#{digest.hexdigest[0, 12]}"
  end

  def self.pinned
    if ENV.fetch("HOTCELL_IMAGE", "") != ""
      ENV["HOTCELL_IMAGE"]
    else
      YAML.safe_load_file(File.join(__dir__, "deploy.yml")).dig("accessories", "hotcell", "image")
    end
  end
end

puts HotcellImage.tag if $PROGRAM_NAME == __FILE__
