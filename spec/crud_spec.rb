require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "CRUD API" do
  before do
    @record_foo = {:id => new_uuid, :title => "Foo", :text => "foo"}
    @record_bar = {:id => new_uuid, :title => "Bar", :text => "bar"}
  end

  after do
    test_adapter.clear!
  end

  share_as :ACollection do
    it { @result.should be_a(Datapathy::Collection) }
    it { @result.first.should be_an(Article) }
  end

  share_as :AnArticle do
    it { @result.should be_an(Article) }
  end

  describe "New" do

    share_as :NewCollection do
      it_should_behave_like ACollection
      it { @result.first.should be_new_record }
    end

    share_as :NewArticle do
      it_should_behave_like AnArticle
      it { @result.should be_new_record }
    end

    describe "Model.new()" do
      before do
        @result = Article.new()
      end
      it_should_behave_like NewArticle
    end

    describe "Model.new({})" do
      before do
        @result = Article.new(@record_foo)
      end
      it_should_behave_like NewArticle
    end

    describe "Model.new({}, {})" do
      before do
        @result = Article.new(@record_foo, @record_bar)
      end
      it_should_behave_like NewCollection
    end

    describe "collection.new()" do
      before do
        @result = Article.all.new()
      end
      it_should_behave_like NewArticle
    end

    describe "collection.new({})" do
      before do
        @result = Article.all.new(@record_foo)
      end
      it_should_behave_like NewArticle
    end

    describe "collection.new({}, {})" do
      before do
        @result = Article.all.new(@record_foo, @record_bar)
      end
      it_should_behave_like NewCollection
    end

  end

  describe "Create" do

    share_as :CreatedCollection do
      it { @result.first.should_not be_new_record }
      it_should_behave_like ACollection
    end

    share_as :CreatedArticle do
      it { @result.should_not be_new_record }
      it_should_behave_like AnArticle
    end

    describe "Model.create({})" do
      before { @result = Article.create(@record_foo) }
      it_should_behave_like CreatedArticle
    end

    describe "Model.create({}, {})" do
      before { @result = Article.create(@record_foo, @record_bar) }
      it_should_behave_like CreatedCollection
    end

    describe "collection.create({})" do
      before do
        @result = Article.all.create(@record_foo)
      end
      it_should_behave_like CreatedArticle
    end

    describe "collection.create({}, {})" do
      before do
        @result = Article.all.create(@record_foo, @record_bar)
      end
      it_should_behave_like CreatedCollection
    end

    describe "existing_collection.create" do
      describe "one" do
        before do
          @result = Datapathy::Collection.new(Article, @record_foo).create
        end
        it_should_behave_like CreatedArticle
      end
      describe "many" do
        before do
          @result = Datapathy::Collection.new(Article, @record_foo, @record_bar).create
        end
        it_should_behave_like CreatedCollection
      end
    end
  end

end
