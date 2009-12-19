require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'deleteing models' do

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

  describe 'one at a time' do
    before do
      Article[@record[:id]].delete
    end

    it 'should remove the record' do
      lambda {
        Article[@record[:id]]
      }.should raise_error(Datapathy::RecordNotFound)
    end

    it 'should not delete other records' do
      Article[@record_b[:id]].should_not be_nil
    end
  end

  describe 'in bulk' do
    before do
      Article.delete { |a| a.title == @record_b[:title] }
    end

    it 'should remove the record(s)' do
      Article.select { |a| a.title == @record_b[:title] }.should be_empty
    end

    it 'should not remove other records' do
      Article[@record[:id]].should_not be_nil
    end

  end


end
