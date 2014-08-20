module AuditTrail
  class ChangeTracker
    def initialize(record, audit_attributes)
      @record = record
      @audit_attributes = audit_attributes
    end

    def track
      initial_state.each do |attr, val|
        initial_state[attr] = record.send(attr)
      end
    end

    def changes
      @changes ||= build_changes
    end

    private

    attr_reader :record, :audit_attributes

    def initial_state
      @initial_state ||= audit_attributes.reduce({}) do |memo, attr|
        memo[attr] = nil
        memo
      end
    end

    def build_changes
      initial_state.reduce({}) do |memo, state|
        apply_diff(memo, *state)
      end
    end

    def apply_diff(memo, attr, old_val)
      new_val = record.send(attr)
      if new_val != old_val
        memo[attr] = {
          new: new_val,
          old: old_val
        }
      end
      memo
    end
  end
end
