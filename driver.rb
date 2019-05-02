require "watir"
class Driver
  attr_reader :browser

  def initialize(browseron=false,type=ENV["browser_type"])
    @browser = browseron ? create_browser(type) : nil
  end
  def create_browser(type = ENV["browser_type"])
    puts "browser type = #{type}"
    case type.downcase
    when "headless"
      require 'headless'
      min_display = 99
      max_display = 10_000
      begin
        tries ||= 3
        display = rand(min_display..max_display)
        puts "Using display: #{display}"
        @headless = Headless.new(:display => display)
        @headless.start
      rescue Headless::Exception => e
        puts e
        raise if tries <= 0
        tries -= 1
        retry
      end
      profile = Selenium::WebDriver::Firefox::Profile.new
      @browser = Watir::Browser.new :firefox, :profile => profile, :headless => true, accept_insecure_certs: true
      @browser.window.resize_to(1920, 1080)
      # @browser.window.maximize
      return @browser
    when "firefox"
      profile = Selenium::WebDriver::Firefox::Profile.new
      profile['startup.homepage_welcome_url'] = "about:blank"
      profile['startup.homepage_welcome_url.additional'] = "about:blank"
      @browser = Watir::Browser.new :firefox, :profile => profile, accept_insecure_certs: true
      @browser.window.resize_to(1920, 1080)
      # @browser.window.maximize
      return @browser
    else
      fail("unknown browser type: #{type}")
    end
  end
end