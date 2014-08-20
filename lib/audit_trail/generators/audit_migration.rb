require 'active_record/migration'

module AuditTrail
  class AuditMigration < ActiveRecord::Migration
    def up
      create_table :audits do |t|
        t.integer :auditable_id
        t.string  :auditable_type
        t.integer :user_id
        t.string  :user_type
        t.string  :action
        t.text    :revisions
        t.timestamps
      end

      add_index :audits, [:auditable_id, :auditable_type]
    end

    def down
      remove_index :audits, [:auditable_id, :auditable_type]
      drop_table :audits
    end
  end
end
