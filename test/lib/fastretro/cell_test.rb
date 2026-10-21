require "test_helper"

class FastRetro::CellTest < ActiveSupport::TestCase
  test "SaaS production requires a cell" do
    FastRetro.stubs(:saas?).returns(true)
    Rails.stubs(:env).returns(ActiveSupport::EnvironmentInquirer.new("production"))
    ENV.stubs(:[]).with("HOTCELL_ROOT").returns(nil)
    ENV.stubs(:[]).with("SECRET_KEY_BASE_DUMMY").returns(nil)

    assert_raises HotCell::ConfigurationError do
      FastRetro::Cell.root
    end
  end

  test "asset builds do not require a running cell" do
    FastRetro.stubs(:saas?).returns(true)
    Rails.stubs(:env).returns(ActiveSupport::EnvironmentInquirer.new("production"))
    ENV.stubs(:[]).with("HOTCELL_ROOT").returns(nil)
    ENV.stubs(:[]).with("SECRET_KEY_BASE_DUMMY").returns("1")

    assert_nil FastRetro::Cell.root
  end

  test "self hosted production can process images without a cell" do
    FastRetro.stubs(:saas?).returns(false)
    Rails.stubs(:env).returns(ActiveSupport::EnvironmentInquirer.new("production"))
    ENV.stubs(:[]).with("HOTCELL_ROOT").returns(nil)

    assert_empty FastRetro::Cell.active_storage_configuration
  end

  test "the application and cell use the same protocol version" do
    cell = Bundler::LockfileParser.new(Rails.root.join("hotcell/Gemfile.lock").read)
    app = Bundler::LockfileParser.new(Rails.root.join("Gemfile.lock").read)

    assert_equal app.specs.find { |spec| spec.name == "hotcell-core" }.version,
      cell.specs.find { |spec| spec.name == "hotcell-core" }.version
  end
end
