require 'audit_trail/trail_builder'

module AuditTrail
  module Auditable
    def audit_trail
      AuditTrail::TrailBuilder.build(self, included_audits)
    end

    def reset_audit_trail_action
      self.audit_trail_action = nil
    end

    def requires_audit?
      !!audit_trail_action
    end

    private

    def set_created_audit
      self.audit_trail_action = :create
    end

    def set_updated_audit
      self.audit_trail_action = :update
    end

    def set_destroyed_audit
      self.audit_trail_action = :destroy
    end
  end
end
