require 'rspec'
require 'eyes_selenium'

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

Applitools::EyesLogger.log_handler = Logger.new(STDOUT)

RSpec.shared_examples 'Test for url' do |url|
  let(:url) { url }
  let(:web_driver) { Selenium::WebDriver.for :chrome }

  let(:config) do
    Applitools::Selenium::Configuration.new.tap do |config|
    config.app_name = 'Top 10 sites'
    config.test_name = "Top 10 sites - #{url}"
    # config.proxy = Applitools::Connectivity::Proxy.new 'http://localhost:8000'
    config.api_key = ENV['APPLITOOLS_API_KEY']
    config.viewport_size = Applitools::RectangleSize.new(800, 600)
    config.add_browser(800, 600, Applitools::Selenium::BrowserTypes::CHROME)
          .add_browser(700, 500, Applitools::Selenium::BrowserTypes::CHROME)
          .add_browser(1600, 1200, Applitools::Selenium::BrowserTypes::CHROME)
          .add_browser(1280, 1024, Applitools::Selenium::BrowserTypes::CHROME)
          .add_device_emulation(Applitools::Selenium::ChromeEmulationInfo.galaxy_s5(:portrait))
          .add_device_emulation(Applitools::Selenium::ChromeEmulationInfo.i_phone_6_7_8_plus(:portrait))
    end
  end

  let(:driver) do
    eyes.config = config
    eyes.open(driver: web_driver)
  end

  let(:target1) { Applitools::Selenium::Target.window.send_dom }
  let(:target2) { Applitools::Selenium::Target.window.fully(true).send_dom }

  let(:eyes) { @eyes }

  after do
    begin
      eyes.close
    ensure
      driver.quit
    end
  end

  it url do
    driver.get(url)
    eyes.check('Step1 ' + url, target1)
    eyes.check('Step2 ' + url, target2)
  end
end

RSpec.describe 'My first visual grid test' do
  before(:all) do
    @runner = Applitools::Selenium::VisualGridRunner.new(3)
    @eyes = Applitools::Selenium::Eyes.new(visual_grid_runner: @runner )
  end

  after(:all) do
    puts @runner.get_all_test_results.map {|r| r.passed? }
    @runner.stop
  end

  it_behaves_like 'Test for url', 'https://youtube.com'
end