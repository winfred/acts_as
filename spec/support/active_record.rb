require 'active_record'

ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"

ActiveRecord::Migrator.up "db/migrate"

ActiveRecord::Migration.create_table :users do |t|
  t.string :name
  t.string :type
  t.integer :clan_id
  t.integer :profile_id
  t.timestamps
end

ActiveRecord::Migration.create_table :rebel_profiles do |t|
  t.string :serial_data
  t.timestamps
end

ActiveRecord::Migration.create_table :imperial_profiles do |t|
  t.string :analog_data
  t.timestamps
end

ActiveRecord::Migration.create_table :clans do |t|
  t.string :name
  t.integer :strength, default: 50
  t.boolean :cool
  t.timestamps
end

ActiveRecord::Migration.create_table :x_wings do |t|
  t.integer :rebel_id
  t.timestamps
end