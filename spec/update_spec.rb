require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'updating models' do

  before do
    @record_a = @record = {:id => new_uuid, :title => "Datapathy is amazing!", :text => "It really is!"}
    @record_b =           {:id => new_uuid, :title => "Datapathy is awesome!", :text => "Try it today!"}
    @record_c =           {:id => new_uuid, :title => "Datapathy is awesome!", :text => "Title is same, but text is different"}

    @records = [@record_a, @record_b, @record_c]
    @records.each do |record|
      test_adapter.datastore[Article][record[:id]] = record.stringify_keys
    end
  end

  after do
    test_adapter.clear!
  end

  describe 'one at a time' do
    before do
      @article = Article[@record[:id]]
      @article.title = "Datapathy is /still/ amazing!"
      @article.save

      @updated_article = Article[@record[:id]]
    end

    it 'should update the attributes' do
      @updated_article.title.should eql(@article.title)
    end

    it 'should not update other attributes' do
      @updated_article.id.should eql(@record[:id])
    end
  end

  describe 'bulk' do

    it 'should update based on a query' do
      articles = Article.update(:text => "Updated Text") { |a|
        a.title == @record_b[:title]
      }

      articles.each do |article|
        updated_article = Article[article.id]
        updated_article.text.should eql("Updated Text")
      end
    end

  end

end


