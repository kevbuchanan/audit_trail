require 'audit_trail/audit'
require 'audit_trail/auditable'
require 'audit_trail/auditor'

module AuditTrail
  module ClassMethods
    def audit(opts)
      include Auditable
      has_many :audits, as: :auditable, class: AuditTrail::Audit
      attr_accessor :audit_trail_action
      after_create :set_created_audit
      after_update :set_updated_audit
      after_destroy :set_destroyed_audit
      define_method :audit_attributes do
        opts[:attributes] || []
      end
      define_method :included_audits do
        opts[:include] || []
      end
    end
  end

  def self.with_user(user)
    AuditBuilder.new(user: user)
  end

  def self.trail(record, &block)
    AuditBuilder.new.trail(record, &block)
  end

  class AuditBuilder
    attr_reader :opts

    def initialize(opts = {})
      @opts = opts
    end

    def trail(record, &block)
      Auditor.new(record, opts).trail(&block)
    end
  end
end

class ActiveRecord::Base
  extend AuditTrail::ClassMethods
end

