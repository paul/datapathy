require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class MyModel
  include Datapathy::Model

  persists :id
  persists :name
end

describe "Datapathy" do

  def uuid
    UUIDTools::UUID.random_create.to_s
  end

  it 'should have attributes' do
    MyModel.persisted_attributes.should == [:id, :name]
  end

  it 'should be able to store and retrieve a record' do
    my_model = MyModel.create(:id => uuid,
                              :name => "Paul")

    other = MyModel[my_model.id]
    other.should == my_model
    other.id.should == my_model.id
    other.name.should == my_model.name
  end

  it 'should be able to retrive all things' do
    a = MyModel.create(:id => uuid,
                       :name => "George")
    b = MyModel.create(:id => uuid,
                       :name => "John")

    results = MyModel.all

    results.should include(a)
    results.should include(b)
  end

  it 'should be able to find things' do
    my_model = MyModel.create(:id => UUIDTools::UUID.random_create.to_s,
                              :name => "Ringo")

    other = MyModel.detect { |r| r.name == "Ringo" }
    other.should == my_model
  end

end
