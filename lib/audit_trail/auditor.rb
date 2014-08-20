require 'audit_trail/errors'
require 'audit_trail/change_tracker'

module AuditTrail
  class Auditor
    def initialize(record, opts = {})
      @record = record
      @options = opts
    end

    def trail(&block)
      raise not_auditable_error unless auditable?
      record.reset_audit_trail_action
      tracker.track
      block.call(record)
      create_audit if audit_required?
      record
    end

    private

    attr_reader :record, :options

    def audit_required?
      record.requires_audit?
    end

    def create_audit
      Audit.create(
        auditable: record,
        user: user,
        action: record.audit_trail_action,
        revisions: tracker.changes
      )
    end

    def user
      options[:user]
    end

    def tracker
      @tracker ||= ChangeTracker.new(record, record.audit_attributes)
    end

    def auditable?
      record.is_a?(AuditTrail::Auditable)
    end

    def not_auditable_error
      RecordNotAuditable.new("class #{record.class} is not auditable")
    end
  end
end
