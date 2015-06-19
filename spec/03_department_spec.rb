require_relative 'spec_helper'

describe Department do

  before do
    Department.create_table
  end

  after do
    Department.drop_table
  end


  describe 'attributes' do 
    it 'has an id, name' do
      attributes = {
        :id => 1,
        :name => "Computer Science"
      }

      comp_sci = Department.new
      comp_sci.id = attributes[:id]
      comp_sci.name = attributes[:name]

      expect(comp_sci.id).to eq(attributes[:id])
      expect(comp_sci.name).to eq(attributes[:name])
    end
  end

  describe '.create_table' do
    it 'creates a departments table' do
      Department.drop_table
      Department.create_table

      table_check_sql = "SELECT tbl_name FROM sqlite_master WHERE type='table' AND tbl_name='departments';"
      expect(DB[:conn].execute(table_check_sql)[0]).to eq(['departments'])
    end
  end

  describe '.drop_table' do
    it "drops the departments table" do
      Department.create_table
      Department.drop_table

      table_check_sql = "SELECT tbl_name FROM sqlite_master WHERE type='table' AND tbl_name='departments';"
      expect(DB[:conn].execute(table_check_sql)[0]).to be_nil
    end
  end

  describe '#insert' do
    it 'inserts the department into the database' do
      comp_sci = Department.new
      comp_sci.name = "Computer Science"

      comp_sci.insert

      select_sql = "SELECT name FROM Departments WHERE name = 'Computer Science'"
      result = DB[:conn].execute(select_sql)[0]

      expect(result[0]).to eq("Computer Science")
    end

    it 'updates the current instance with the ID of the Department from the database' do
      comp_sci = Department.new
      comp_sci.name = "Computer Science"

      comp_sci.insert

      expect(comp_sci.id).to eq(1)
    end
  end

  describe '.new_from_db' do
    it 'creates an instance with corresponding attribute values' do
      row = [1, "Computer Science"]
      comp_sci = Department.new_from_db(row)

      expect(comp_sci.id).to eq(row[0])
      expect(comp_sci.name).to eq(row[1])
    end
  end

  describe '.find_by_name' do
    it 'returns an instance of department that matches the name from the DB' do
      comp_sci = Department.new
      comp_sci.name = "Computer Science"
      comp_sci.insert


      comp_sci_from_db = Department.find_by_name("Computer Science")
      expect(comp_sci_from_db.name).to eq("Computer Science")
      expect(comp_sci_from_db).to be_an_instance_of(Department)
    end
  end

  describe '.find_by_id' do
    it "finds by id" do
      comp_sci = Department.new
      comp_sci.name = "Computer Science"
      comp_sci.insert

      comp_sci_from_db = Department.find_by_id(comp_sci.id)
      expect(comp_sci_from_db.name).to eq("Computer Science")
      expect(comp_sci_from_db).to be_an_instance_of(Department)
    end
  end

  describe "#update" do
    it 'updates and persists a department in the database' do
      comp_sci = Department.new
      comp_sci.name = "Computer Science"
      comp_sci.insert

      comp_sci.name = "Communications"
      original_id = comp_sci.id

      comp_sci.update

      comp_sci_from_db = Department.find_by_name("Computer Science")
      expect(comp_sci_from_db).to be_nil

      bob_from_db = Department.find_by_name("Communications")
      expect(bob_from_db).to be_an_instance_of(Department)
      expect(bob_from_db.name).to eq("Communications")
      expect(bob_from_db.id).to eq(original_id)
    end
  end

  describe '#save' do
    it "chooses the right thing on first save" do
      comp_sci = Department.new
      comp_sci.name = "Computer Science"
      expect(comp_sci).to receive(:insert)
      comp_sci.save
    end

    it 'chooses the right thing for all others' do
      comp_sci = Department.new
      comp_sci.name = "Computer Science"
      comp_sci.save

      comp_sci.name = "Communications"
      expect(comp_sci).to receive(:update)
      comp_sci.save      
    end
  end

end



