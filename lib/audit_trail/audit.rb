require 'active_record'

module AuditTrail
  class Audit < ActiveRecord::Base
    belongs_to :auditable, polymorphic: true
    belongs_to :user, polymorphic: true

    serialize :revisions
  end
end
