require 'spec_helper'

describe "URI-Templated query params" do
  before do
    Datapathy.configure do |config|
      config.services_uri = "http://datapathy.dev/"
    end

    Artifice.activate_with(DatapathyTestApp)
  end

  after do
    Artifice.deactivate
  end

  it "should translate filterable attributes to query params" do
    comments = Comments.select { |c| c.author_href = "/authors/1" }
    comments.href.should == "/comments?author_href=/authors/1"
  end

end



