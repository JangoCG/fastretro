require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  browser_options = lambda do |headless: false|
    Selenium::WebDriver::Chrome::Options.new.tap do |opts|
      opts.add_argument("--window-size=1200,800")
      opts.add_argument("--disable-extensions")
      opts.add_argument("--disable-renderer-backgrounding")
      opts.add_argument("--disable-backgrounding-occluded-windows")
      opts.add_argument("--deny-permission-prompts")
      opts.add_argument("--enable-automation")
      opts.add_argument("--headless") if headless
    end
  end

  Capybara.register_driver :chrome_headless do |app|
    Capybara::Selenium::Driver.new(app, browser: :chrome, options: browser_options.call(headless: true))
  end

  Capybara.register_driver :chrome do |app|
    Capybara::Selenium::Driver.new(app, browser: :chrome, options: browser_options.call)
  end

  if ENV["SYSTEM_TESTS_BROWSER"]
    driven_by :chrome, screen_size: [ 1200, 1000 ]
  else
    driven_by :chrome_headless, screen_size: [ 1200, 1000 ]
  end
end
