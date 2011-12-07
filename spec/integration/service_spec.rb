require 'spec_helper'

describe "top-level service" do
  before do
    Datapathy.configure do |config|
      config.services_uri = "http://datapathy.dev/"
    end

    Artifice.activate_with(DatapathyTestApp)
  end

  after do
    Artifice.deactivate
  end

  it "should work" do
    services = Service.all
    services.size.should == 2
  end

end

