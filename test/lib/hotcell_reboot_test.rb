require "test_helper"
load Rails.root.join("hotcell/bin/reboot")

class HotcellRebootTest < ActiveSupport::TestCase
  setup do
    @accessory = stub(image: "localhost:5555/fastretro-hotcell:abc123", hosts: %w[web-1 web-2])
    KAMAL.stubs(:configured?).returns(true)
    KAMAL.stubs(:accessory).with("hotcell").returns(@accessory)
    KAMAL.stubs(:accessory_hosts).returns(%w[web-2 jobs-1])
    KAMAL.stubs(:config).returns(stub(ssh: stub(options: { user: "deploy", port: 2222 })))
  end

  test "the local registry is forwarded to selected cell hosts throughout the reboot" do
    forwarding = mock
    Kamal::Cli::Build::PortForwarding.expects(:new)
      .with([ "web-2" ], 5555, user: "deploy", port: 2222).returns(forwarding)

    rebooting = false
    forwarding.define_singleton_method(:forward) do |&block|
      rebooting = true
      block.call
    ensure
      rebooting = false
    end

    Kamal::Cli::Accessory.any_instance.expects(:reboot).with("hotcell") do
      assert rebooting
      true
    end

    HotcellReboot.start([])
    assert_not rebooting
  end

  test "a remote registry does not open an SSH tunnel" do
    @accessory.stubs(:image).returns("registry.example.com/fastretro-hotcell:abc123")
    Kamal::Cli::Build::PortForwarding.expects(:new).never
    Kamal::Cli::Accessory.any_instance.expects(:reboot).with("hotcell")

    HotcellReboot.new.reboot("hotcell")
  end

  test "a failed reboot propagates to the release command chain" do
    forwarding = mock
    Kamal::Cli::Build::PortForwarding.stubs(:new).returns(forwarding)
    forwarding.define_singleton_method(:forward) { |&block| block.call }
    Kamal::Cli::Accessory.any_instance.expects(:reboot).with("hotcell").raises(SSHKit::Command::Failed, "pull failed")

    assert_raises SSHKit::Command::Failed do
      HotcellReboot.new.reboot("hotcell")
    end
  end

  test "the Kamal reboot pulls the image inside the tunnel with accessory hook metadata" do
    config = Kamal::Configuration.new({
      service: "hotcell-test", image: "fastretro", servers: %w[web-1 web-2],
      registry: { "server" => "localhost:5555", "username" => "unused", "password" => "unused" },
      builder: { "arch" => "amd64" },
      accessories: { "hotcell" => { "image" => @accessory.image, "hosts" => %w[web-1 web-2] } }
    }, version: "test")
    KAMAL.stubs(:config).returns(config)
    KAMAL.stubs(:accessory).with("hotcell").returns(Kamal::Commands::Accessory.new(config, name: "hotcell"))
    KAMAL.stubs(:modify).with(command: "accessory", subcommand: "reboot").yields
    KAMAL.stubs(:holding_lock?).returns(true)

    forwarding = mock
    Kamal::Cli::Build::PortForwarding.stubs(:new).returns(forwarding)
    forwarding_active = false
    forwarding.define_singleton_method(:forward) do |&block|
      forwarding_active = true
      block.call
    ensure
      forwarding_active = false
    end

    HotcellReboot.no_commands do
      HotcellReboot.any_instance.stubs(:on).with([ "web-2" ]).yields("web-2")
      HotcellReboot.any_instance.stubs(:execute)
      HotcellReboot.any_instance.stubs(:capture_with_info).returns("")
      HotcellReboot.any_instance.stubs(:upload!)
      HotcellReboot.any_instance.expects(:execute).with(:docker, :image, :pull, @accessory.image) do
        assert forwarding_active
        true
      end
    end

    HotcellReboot.start([])
    assert_not forwarding_active
  end
end
