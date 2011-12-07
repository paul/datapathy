require 'spec_helper'

describe "overriding service endpoint with .service_uri=" do

  before do
    Datapathy.configure { |c| c.services_uri = "http://datapathy.dev/" }
    Artifice.activate_with(DatapathyTestApp)
  end

  after do
    Artifice.deactivate
  end

  it "should normally discover the endpoint" do
    collection = Post.all
    collection.load!
    collection.href.should == "http://datapathy.dev/posts"
  end

  it "should get resources from the given endpoint" do
    Post.service_uri = "http://datapathy.dev/my_posts"
    collection = Post.all
    collection.load!
    collection.href.should == "http://datapathy.dev/my_posts"
  end

  it "should get resources from the given endpoint relative to the Datapathy.services_uri" do
    Post.service_uri = "/my_posts"
    collection = Post.all
    collection.load!
    collection.href.should == "http://datapathy.dev/my_posts"
  end
end
