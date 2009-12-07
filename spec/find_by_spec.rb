require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Model.find_by_foo" do

  before do
    @article = Article.create(:id => new_uuid,
                              :title => "FooBar",
                              :text  => "Original text")
  end

  it 'should find one' do
    article = Article.find_by_title("FooBar")

    article.text.should == "Original text"
  end

  after do
    test_adapter.clear!
  end


end


