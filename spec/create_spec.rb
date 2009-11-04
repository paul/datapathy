require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Creating models" do

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
      @article = Article.create(:id => new_uuid, 
                                :title => "Datapathy is awesome!", 
                                :text => "It just is!")
    end

    it_should_behave_like CreatingARecord
    
  end

  describe 'Model.new; #save' do
    before do
      @article = Article.new(:id => new_uuid, 
                             :title => "Datapathy is awesome!", 
                             :text => "It just is!")
      @article.save
    end

    it_should_behave_like CreatingARecord

  end

  describe 'Bulk Model.create' do
    before do
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
