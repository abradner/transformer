class CreateTransformations < ActiveRecord::Migration[8.0]
  def change
    create_table :transformations do |t|
      t.string :name, null: false
      t.text :description
      t.text :transformations_yaml, null: false # Contains just the 'transformations' array from YAML
      t.string :transformation_type, null: false
      t.string :version, default: '1.0.0', null: false # Semver string instead of integer

      t.timestamps
    end

    # Indexes for performance
    add_index :transformations, :name, unique: true # Global unique names for now
    add_index :transformations, :transformation_type
    add_index :transformations, :version

    # Constraints
    add_check_constraint :transformations, "length(name) > 0", name: "name_not_empty"
    add_check_constraint :transformations, "length(transformations_yaml) > 0", name: "transformations_yaml_not_empty"
  end
end
