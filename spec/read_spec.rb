require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'reading models' do

  before do
    @record_a = @record = {:id => new_uuid, :title => "Datapathy is amazing!", :text => "It really is!"}
    @record_b =           {:id => new_uuid, :title => "Datapathy is awesome!", :text => "Try it today!"}
    @record_c =           {:id => new_uuid, :title => "Datapathy is awesome!", :text => "Title is same, but text is different"}

    @records = [@record_a, @record_b, @record_c]
    @records.each do |record|
      test_adapter.datastore[Article][record[:id]] = record
    end
  end

  after do
    test_adapter.clear!
  end

  describe 'Model.all' do
    before do
      @articles = Article.all
    end

    it 'should retrive all records' do
      @articles.should have(@records.size).items
    end
  end

  describe 'Model.[]' do
    before do
      @article = Article[@record[:id]]
    end

    it 'should retrive it by key' do
      @article.should_not be_nil
    end

    it 'should load the attributes' do
      [:id, :title, :text].each do |atr|
        @article.send(atr).should eql(@record[atr])
      end
    end
  end

  describe 'Model.detect' do
    before do
      @article = Article.detect { |a| a.title == @record_b[:title] }
    end

    it 'should retrieve only one record' do
      @article.should be_a(Article)
    end

    it 'should retrieve the correct record' do
      @article.title.should eql(@record_b[:title])
    end

  end

  describe 'Model.select' do

    describe '(&blk)' do
      before do
        @articles = Article.select { |a| a.title == @record_b[:title] }
      end

      it 'should retrieve all matching records' do
        @articles.should have(2).items
      end

      it 'should retrieve the correct records' do
        @articles.map { |a| a.id }.should include(@record_b[:id])
        @articles.map { |a| a.id }.should include(@record_c[:id])
      end
    end

  end

end

