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

end
