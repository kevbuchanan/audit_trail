require 'bundler/setup'
Bundler.setup

require 'active_record'
require 'audit_trail'
require 'audit_trail/generators/audit_migration'

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: ':memory:'
)

class TestSchema < ActiveRecord::Migration
  def change
    create_table :authors do |t|
      t.string :name
      t.string :email
      t.string :address
    end

    create_table :books do |t|
      t.string  :title
      t.integer :author_id
      t.boolean :is_published
    end

    create_table :users do |t|
      t.string :name
    end
  end
end

TestSchema.migrate(:up)
AuditTrail::AuditMigration.migrate(:up)

RSpec.configure do |config|
  config.after(:each) do
    ActiveRecord::Base.subclasses.each(&:destroy_all)
  end
end
