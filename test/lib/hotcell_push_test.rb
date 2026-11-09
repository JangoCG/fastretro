require "test_helper"
require "open3"
require "tmpdir"
require_relative "../../hotcell/image"

class HotcellPushTest < ActiveSupport::TestCase
  test "an ARM64 image can be published for the production host" do
    output, status, commands = run_push("arm64")

    assert status.success?, output
    assert_includes commands, "push #{HotcellImage.tag}"
  end

  test "an AMD64 image is rejected before publishing" do
    output, status, commands = run_push("amd64")

    assert_not status.success?
    assert_includes output, "hosts are arm64"
    assert_not_includes commands, "push "
  end

  private
    def run_push(architecture)
      Dir.mktmpdir("hotcell-push") do |directory|
        docker = File.join(directory, "docker")
        record = File.join(directory, "commands")
        File.write(docker, <<~SH)
          #!/usr/bin/env bash
          echo "$*" >> "$PUSH_RECORD"
          if [ "$1 $2" = "image inspect" ]; then echo "$PUSH_ARCH"; fi
        SH
        File.chmod(0o755, docker)

        output, status = Open3.capture2e({ "PATH" => "#{directory}:#{ENV.fetch("PATH")}", "PUSH_ARCH" => architecture,
          "PUSH_RECORD" => record, "HOTCELL_IMAGE_REPOSITORY" => nil }, Rails.root.join("hotcell/bin/push").to_s)

        [ output, status, File.read(record) ]
      end
    end
end
