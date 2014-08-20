require 'spec_helper'

describe AuditTrail do
  class Author < ActiveRecord::Base
    audit attributes: [:name, :email, :address]

    has_many :books
  end

  class Book < ActiveRecord::Base
    audit attributes: [:title], include: [:author]

    belongs_to :author
  end

  class User < ActiveRecord::Base
  end

  let(:author) {
    Author.create(
      name: "Joe",
      email: "joe@example.com",
      address: "1 Main st"
    )
  }

  let(:book) {
    Book.create(
      title: "A Good Book",
      author: author,
      is_published: false
    )
  }

  let(:user) { User.create(name: "me") }

  let(:now) { Time.now.utc.to_s }

  it 'creates an audit' do
    AuditTrail.trail(author) do
      author.update_attributes(name: "new name")
    end

    expect(author.audits.count).to eq(1)
  end

  it 'builds an audit trail' do
    AuditTrail.trail(author) do
      author.update_attributes(name: "new name")
    end

    AuditTrail.trail(author) do
      author.update_attributes(
        address: "2 Main st",
        email:   "new@new-url.com",
      )
      author.books << Book.new(title: "New book")
      author.save
    end

    expect(author.audit_trail).to eq(
      [
        {
          date: now,
          action: :update,
          user: nil,
          changes: {
            address: {
              old: "1 Main st",
              new: "2 Main st"
            },
            email: {
              old: "joe@example.com",
              new: "new@new-url.com"
            }
          }
        },
        {
          date: now,
          action: :update,
          user: nil,
          changes: {
            name: {
              old: "Joe",
              new: "new name"
            }
          }
        },
      ]
    )
  end

  it 'raises an error if a record is not auditable' do
    class Foo; end

    expect { AuditTrail.trail(Foo.new) }.to raise_error(AuditTrail::RecordNotAuditable)
  end

  it 'does not mutate the record by reloading' do
    audited_author = AuditTrail.trail(author) do
      author.name = 'new name'
    end

    expect(audited_author.name).to eq('new name')
    expect(author.audits.count).to eq(0)
  end

  context 'user' do
    it 'can track the user that made the change' do
      AuditTrail.with_user(user).trail(author) do
        author.name = 'new name'
        author.save
      end

      expect(author.audits.last.user).to eq(user)
    end
  end

  context 'destroy' do
    it 'creates a destroyed audit with the user' do
      AuditTrail.with_user(user).trail(author) do
        author.destroy
      end

      expect(author.audits.last.user).to eq(user)
      expect(author.audit_trail).to eq(
        [
          {
            date: now,
            user: user.as_json,
            action: :destroy,
            changes: {}
          }
        ]
      )
    end
  end

  context 'create' do
    it 'creates a created audit with the user' do
      author_attrs = {
        name: 'new name',
        address: 'new address',
        email: 'new email'
      }

      AuditTrail.with_user(user).trail(Author.new) do |new_author|
        new_author.assign_attributes(author_attrs)
        if new_author.valid?
          new_author.save
        end
        new_author
      end

      expect(Author.first.audits.last.user).to eq(user)
      expect(Author.first.audit_trail).to eq(
        [
          {
            date: now,
            action: :create,
            user: user.as_json,
            changes: {
              name: {
                old: nil,
                new: "new name"
              },
              address: {
                old: nil,
                new: "new address"
              },
              email: {
                old: nil,
                new: "new email"
              }
            }
          }
        ]
      )
    end
  end

  context 'included audits' do
    it 'adds the audits for the included association to the audit trail' do
      new_book = AuditTrail.trail(Book.new) do |book|
        book.title = "A Book"
        book.author = author
        book.save
      end

      AuditTrail.trail(author) do
        author.update_attributes(name: 'New name')
      end

      expect(new_book.audit_trail).to eq(
        [
          {
            date: now,
            action: :update,
            user: nil,
            association: :author,
            changes: {
              name: {
                old: 'Joe',
                new: 'New name'
              }
            }
          },
          {
            date: now,
            action: :create,
            user: nil,
            changes: {
              title: {
                old: nil,
                new: 'A Book'
              }
            }
          }
        ]
      )
    end
  end
end
