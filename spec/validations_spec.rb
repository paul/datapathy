require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "validations" do

  describe "enforced by the model" do
    before do
      @person = Person.new(:id => new_uuid)
    end

    it 'should be invalid' do
      @person.name.should == nil
      @person.valid?.should be_false
      @person.should have_errors_on(:name)
    end
  end

  describe "enforced by the adapter" do
    before do
      @id = new_uuid
      @person = Person.create(:id => @id, :name => "Paul")
    end

    it 'should be invalid' do
      person2 = Person.create(:id => @id, :name => "Rando")
      person2.valid?.should be_false
      person2.should have_errors_on(:id)
    end
  end

end

