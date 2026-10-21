require "digest"

module HotcellImage
  def self.tag
    files = %w[ Dockerfile Gemfile Gemfile.lock config.rb ] + Dir.glob("operations/*.rb", base: __dir__).sort
    digest = Digest::SHA256.new

    files.each do |file|
      digest.update(file).update("\0").update(File.binread(File.join(__dir__, file))).update("\0")
    end

    "#{ENV.fetch("HOTCELL_IMAGE_REPOSITORY", "localhost:5555/fastretro-hotcell")}:#{digest.hexdigest[0, 12]}"
  end
end

puts HotcellImage.tag if $PROGRAM_NAME == __FILE__
