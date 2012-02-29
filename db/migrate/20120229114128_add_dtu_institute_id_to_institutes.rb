class AddDtuInstituteIdToInstitutes < ActiveRecord::Migration
  def change
    add_column :institutes, :dtu_institute_id, :integer
  end
end
