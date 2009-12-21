require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'Adapter API' do

  share_as :ArrayOfHashes do
    it 'should return an Array(Hash) of records' do
      @results.should be_an(Array)
      @results.should have(1).item

      result = @results.first
      result.should be_a(Hash)
    end
  end


  before do
    @adapter = Datapathy::Adapters::MemoryAdapter.new
  end

  describe "#create(collection)" do
    before do
      @article = Article.new(:id => new_uuid,
                             :title => "Whee!",
                             :text  => "This is fun!")
      @collection = Datapathy::Collection.new(@article)

      @results = @adapter.create(@collection)
      @result = @results.first
    end

    it_should_behave_like ArrayOfHashes

    it 'should return the populated attributes' do
      @result.should == @article.persisted_attributes
    end
  end

  describe "#read(query)" do
    before do
      @article = Article.new(:id => new_uuid,
                             :title => "Whee!",
                             :text  => "This is fun!")

      @adapter.datastore[Article][@article.id] = @article.persisted_attributes

      @query = Datapathy::Query.new(Article) { |q| q.title == @article.title }

      @results = @adapter.read(@query)
      @result = @results.first
    end

    it_should_behave_like ArrayOfHashes

    it 'should have the attributes' do
      @result.should == @article.persisted_attributes
    end
  end

  describe "#update(attributes, collection)" do
    before do
      @article = Article.new(:id => new_uuid,
                             :title => "Whee!",
                             :text  => "This is fun!")

      @adapter.datastore[Article][@article.id] = @article.persisted_attributes
    end

    describe "with loaded collection (update already retrived records)" do
      before do
        @collection = @article.collection
        @collection.should be_loaded
        @results = @adapter.update({:title => "Boo"}, @collection)
        @result = @results.first
      end

      it_should_behave_like ArrayOfHashes

      it 'should return the update attribute values' do
        @result[:title].should == "Boo"
      end
    end

    describe "with empty collection (update in bulk, without retrieval)" do
      before do
        @query = Datapathy::Query.new(Article) { |q| q.title == @article.title }
        @collection = Datapathy::Collection.new(@query)
        @collection.should_not be_loaded

        @results = @adapter.update({:title => "Boo"}, @collection)
        @result = @results.first
      end

      it_should_behave_like ArrayOfHashes

      it 'should return an updated attribute values' do
        @result[:title].should == "Boo"
      end
    end

  end

  describe "#delete(attributes)" do
    before do
      @article = Article.new(:id => new_uuid,
                             :title => "Whee!",
                             :text  => "This is fun!")

      @adapter.datastore[Article][@article.id] = @article.persisted_attributes
    end

    describe "with loaded collection (delete already retrived records)" do
      before do
        @collection = @article.collection
        @collection.should be_loaded
        @results = @adapter.delete(@collection)
        @result = @results.first
      end

      it_should_behave_like ArrayOfHashes

      it 'should return the remove attributes' do
        @result.should == @article.persisted_attributes
      end
    end

    describe "with empty collection (delete in bulk, without retrieval)" do
      before do
        @query = Datapathy::Query.new(Article) { |q| q.title == @article.title }
        @collection = Datapathy::Collection.new(@query)
        @collection.should_not be_loaded

        @results = @adapter.delete(@collection)
        @result = @results.first
      end

      it_should_behave_like ArrayOfHashes

      it 'should return the removed attribute values' do
        @result.should == @article.persisted_attributes
      end
    end

  end

end
