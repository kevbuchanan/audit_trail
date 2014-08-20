require 'spec_helper'
require 'audit_trail/audit'

describe AuditTrail::Audit do
  let(:audit) {
    described_class.create(
      action: "update",
      revisions: { one: 1 }
    )
  }

  let(:user) { User.create }

  it "has an action" do
    expect(audit.action).to eq("update")
  end

  it "has serialized revisions" do
    expect(audit.revisions[:one]).to eq(1)
  end

  it "belongs to an audited item" do
    audit.update_attributes(auditable: user)
    expect(audit.auditable).to eq(user)
  end

  it "can belong to a user" do
    audit.update_attributes(user: user)
    expect(audit.user).to eq(user)
  end
end
