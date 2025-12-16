namespace :dev do
  desc "Toggle using Letter Opener to preview emails"
  task :email do
    file_path = Rails.root.join("tmp", "email-dev.txt")

    if File.exist?(file_path)
      File.delete(file_path)
      puts "Letter Opener turned off"
    else
      FileUtils.touch(file_path)
      puts "Letter Opener turned on"
    end

    %x(bin/rails restart)
  end
end
