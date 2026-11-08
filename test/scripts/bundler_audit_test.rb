require "test_helper"
require "open3"
require "tmpdir"
require "timeout"

class BundlerAuditTest < ActiveSupport::TestCase
  test "the audit entrypoint waits for the shared advisory lock and resumes afterwards" do
    Dir.mktmpdir("fastretro-advisory") do |directory|
      environment = { "BUNDLER_AUDIT_DB" => File.join(directory, "advisories") }
      command = [ RbConfig.ruby, Rails.root.join("bin/bundler-audit").to_s, "version" ]
      output, errors, status = Open3.capture3(environment, *command)
      assert status.success?, errors
      assert_match(/bundler-audit \d/, output)

      File.open(File.join(directory, "advisories.lock"), File::RDWR | File::CREAT) do |lock|
        lock.flock File::LOCK_EX
        Open3.popen3(environment, *command) do |input, stdout, stderr, process|
          input.close
          begin
            assert_nil IO.select([ stdout ], nil, nil, 2), "The audit CLI ran while another checkout held its advisory lock"
          ensure
            lock.flock File::LOCK_UN
          end
          assert Timeout.timeout(10) { process.value }.success?, stderr.read
          assert_match(/bundler-audit \d/, stdout.read)
        end
      end
    end
  end
end
