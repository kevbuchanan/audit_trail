require 'spec_helper'
require 'audit_trail/change_tracker'

describe AuditTrail::ChangeTracker do

  class Thing
    attr_accessor :name, :description

    def initialize(name, description)
      @name = name
      @description = description
    end
  end

  let(:thing) { Thing.new("Desk", "A desk") }

  let(:tracker) {
    described_class.new(
      thing,
      [:name, :description]
    )
  }

  context 'changes before tracking' do
    it 'returns all attribute values with no old values' do
      thing.name = "Chair"
      expect(tracker.changes).to eq(
        {
          name: {
            new: "Chair",
            old: nil
          },
          description: {
            new: "A desk",
            old: nil
          }
        }
      )
    end
  end

  context 'changes after tracking' do
    it 'returns changed attribute values and old values at the time of tracking' do
      tracker.track
      thing.name = "Chair"
      expect(tracker.changes).to eq(
        {
          name: {
            new: "Chair",
            old: "Desk"
          }
        }
      )
    end
  end
end
