module AuditTrail
  class TrailBuilder
    def initialize(record, associations)
      @record = record
      @associations = associations
    end

    def self.build(record, associations)
      new(record, associations).audit_trail
    end

    def audit_trail
      (audits + additional_audits).sort_by do |audit|
        audit[:date]
      end.reverse
    end

    private

    attr_reader :record, :associations

    def audits
      record.audits.map { |audit| serialize(audit) }
    end

    def additional_audits
      associations.map do |attr|
        record.send(attr).audits.map do |audit|
          serialize(audit).merge(association: attr)
        end
      end.flatten
    end

    def serialize(audit)
      {
        date: audit.created_at.to_s,
        user: audit.user.as_json,
        action: audit.action.to_sym,
        changes: audit.revisions
      }
    end
  end
end
