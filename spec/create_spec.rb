require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Creating models" do
  before do
    @record_foo = {:id => new_uuid, :title => "Foo", :text => "foo"}
    @record_bar = {:id => new_uuid, :title => "Bar", :text => "bar"}
  end

  it "should create one at a time" do
    result = Article.create(@record_foo)

    result.should be_an(Article)
    result.should_not be_new_record
  end

  it "should create many" do
    result = Article.create(@record_foo, @record_bar)

    result.should be_a(Collection)
    result.first.should be_an(Article)
    result.first.should_not be_new_record
  end

  it "should create a record in an existing collection of one" do
    result = Article.new(@record_foo).create

    result.should be_an(Article)
    result.should_not be_new_record
  end

  it "should create one through a collection" do
    result = Article.all.create(@record_foo)

    result.should be_an(Article)
    result.should_not be_new_record
  end

  it "should create many through a collection" do
    result = Article.all.create(@record_foo, @record_bar)

    result.should be_a(Collection)
    result.first.should be_an(Article)
    result.first.should_not be_new_record
  end


  share_as :CreatingARecord do
    it 'should create a record' do
      test_adapter.datastore[Article].should have(1).key
    end

    it 'should store persistable attributes' do
      record = test_adapter.datastore[Article][@article.id]

      record[:id].should    eql(@article.id)
      record[:title].should eql(@article.title)
      record[:text].should  eql(@article.text)
    end

    it 'should not store other attributes' do
      record = test_adapter.datastore[Article][@article.id]

      @article.should respond_to(:summary)
      record.should_not have_key("summary")
    end
  end

  describe 'Model.create' do
    before do
      pending
      @article = Article.create(:id => new_uuid,
                                :title => "Datapathy is awesome!",
                                :text => "It just is!")
    end

    it_should_behave_like CreatingARecord

  end

  describe 'Model.new; #save' do
    before do
      pending
      @article = Article.new(:id => new_uuid,
                             :title => "Datapathy is awesome!",
                             :text => "It just is!")
      @article.save
    end

    it_should_behave_like CreatingARecord

  end

  describe 'Bulk Model.create' do
    before do
      pending
      @articles = Article.create([
        { :id => new_uuid, :title => "Article A", :text => "Foo"},
        { :id => new_uuid, :title => "Article B", :text => "Bar"},
        { :id => new_uuid, :title => "Article C", :text => "Baz"}
      ])
    end

    it 'should create the records' do
      test_adapter.datastore[Article].should have(@articles.size).keys
    end

  end

  after do
    test_adapter.clear!
  end

end
