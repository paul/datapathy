require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Datapathy" do

  before do
    class MyModel
      include Datapathy::Model

      persists :id
      persists :name
    end unless defined?(MyModel)
  end

  it 'should have attributes' do
    MyModel.persisted_attributes.should == [:id, :name]
  end

  it 'should be able to store and retrieve a record' do
    my_model = MyModel.create(:id => UUIDTools::UUID.random_create,
                              :name => "Paul")

    other = MyModel[my_model.id]
    my_model.id.should == other.id
    my_model.name.should == other.name
  end
end
