require 'spec_helper'

describe "top-level service" do
  before do
    Datapathy.adapters[:http] = Datapathy::Adapters::HttpAdapter.new(:services_uri => "http://datapathy.dev/")
    Datapathy.adapters[:default] = Datapathy.adapters[:http]

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

