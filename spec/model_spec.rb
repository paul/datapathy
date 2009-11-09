require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Defining models" do

  class PersistenceAuthority
    include Datapathy::Model

    persists :id

    persists :both
    persists :client_only
    persists :adapter_only
  end

  describe 'attributes settable by the client and the adapter' do

    it 'should be settable by the client' do
      lambda {
        PersistenceAuthority.new(:both => "foo")
      }.should_not raise_error

      lambda {
         m = PersistenceAuthority.new
         m.both = "foo"
      }.should_not raise_error
    end

    it 'should be settable by the adapter' do
      id = new_uuid
      record = {:id => id, :both => "foobar"}
      test_adapter.datastore[PersistenceAuthority][id] = record

      lambda {
        m = PersistenceAuthority[id]
        m.both
      }.should_not raise_error
    end

    it 'should be peristed to the adapter' do
      id = new_uuid

      PersistenceAuthority.create(:id => id, :both => "foobar")
      test_adapter.datastore[PersistenceAuthority][id][:both].should == "foobar"
    end
  end

  describe 'should have attributes settable only by the adapter' do

    it 'should raise an error if set by the client' do
      lambda {
        PersistenceAuthority.new(:adapter_only => "foo")
      }.should raise_error(NoMethodError)

      lambda {
         m = PersistenceAuthority.new
         m.adapter_only = "foo"
      }.should raise_error(NoMethodError)
    end

    it 'should be settable by the adapter' do
      id = new_uuid
      record = {:id => id, :adapter_only => "foobar"}
      test_adapter.datastore[PersistenceAuthority][id] = record

      lambda {
        m = PersistenceAuthority[id]
        m.adapter_only
      }.should_not raise_error
    end

    it 'should be peristed to the adapter' do
      id = new_uuid

      PersistenceAuthority.create(:id => id, :adapter_only => "foobar")
      test_adapter.datastore[PersistenceAuthority][id][:adapter_only].should == "foobar"
    end

  end

  describe 'should have attributes settable only by the client'  do

    it 'should be settable by the client' do
      lambda {
        PersistenceAuthority.new(:client_only => "foo")
      }.should_not raise_error

      lambda {
         m = PersistenceAuthority.new
         m.client_only = "foo"
      }.should_not raise_error
    end

    it 'should raise an error if set by the adapter' do
      id = new_uuid
      record = {:id => id, :client_only => "foobar"}
      test_adapter.datastore[PersistenceAuthority][id] = record

      lambda {
        m = PersistenceAuthority[id]
        m.client_only
      }.should raise_error(NoMethodError)
    end

    it 'should be persisted to the adapter' do
      id = new_uuid

      PersistenceAuthority.create(:id => id, :client_only => "foobar")
      test_adapter.datastore[PersistenceAuthority][id][:client_only].should == "foobar"
    end

  end

end

