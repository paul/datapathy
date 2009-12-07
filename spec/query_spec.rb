require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'active_support/core_ext/array/wrap'

require 'active_support/core_ext/numeric/time'
require 'active_support/core_ext/object/acts_like'
require 'active_support/core_ext/time/acts_like'
require 'active_support/core_ext/time/calculations'

describe 'querying models' do

  before do
    @record_a = @record = {:id => new_uuid, :title => "Datapathy is amazing!", :text => "It really is!", :published_at => 2.days.ago }
    @record_b =           {:id => new_uuid, :title => "Datapathy is awesome!", :text => "Try it today!", :published_at => 1.day.ago }
    @record_c =           {:id => new_uuid, :title => "Datapathy is awesome!", :text => "Title is same, but text is different", :published_at => 1.minute.ago }

    @records = [@record_a, @record_b, @record_c]
    @records.each do |record|
      test_adapter.datastore[Article][record[:id]] = record
    end
  end

  after do
    test_adapter.clear!
  end

  Spec::Matchers.define :include_records do |*expected_records|
    match do |matched_records|
      @expected_records = expected_records
      matched_keys = matched_records.map { |r| r.id }
      expected_keys = expected_records.map { |r| r[:id] }
      expected_keys.all? { |key| matched_keys.include?(key) }
    end
    failure_message_for_should do |matched_records|
      "Expected #{matched_records.to_a.inspect} to include all of #{@expected_records.inspect}"
    end

  end

  describe '(&blk)' do

    it 'should match ==' do
      Article.select { |a| a.title == "Datapathy is awesome!" }.
        should include_records(@record_b, @record_c)
    end

  end

  describe '{hash}' do
    before do
      @articles = Article.select(:title => @record_b[:title])
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

