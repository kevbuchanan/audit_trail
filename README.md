# Audit Trail

A minimal change tracker for ActiveRecord models.

## Usage

### Making a model auditable

```ruby
class MyModel < ActiveRecord::Base
  audit attributes: [:title, :description]
end
```

Create a migration:

```ruby
class AuditMigration < ActiveRecord::Migration
  def up
    AuditTrail::AuditMigration.migrate(:up)
  end

  def down
    AuditTrail::AuditMigration.migrate(:down)
  end
end
```

### Tracking changes

Creating:

```ruby
AuditTrail.trail(MyModel.new) do |model|
  model.title = 'New model'
  model.save
end
```

Updating:

```ruby
instance = MyModel.find(1)

AuditTrail.trail(instance) do
  instance.update_attributes(title: 'Another title')
end
```

Destroying:

```ruby
AuditTrail.trail(MyModel.find(1)) do |instance|
  instance.destroy
end
```

### Tracking users

```ruby
instance = MyModel.find(1)

AuditTrail.with_user(current_user).trail(instance) do
  instance.update_attributes(title: 'Another title')
end

instance.audits.last.user #=> current_user
```

### Viewing the audit trail

```ruby
MyModel.first.audit_trail #=>
#   [
#     {
#       date: <date of change>,
#       action: <:create, :update, or :destroy>,
#       user: <user>,
#       changes: {
#         name: {
#           old: <previous_name>,
#           new: <new_name>
#         }
#       }
#     }
#   ]
```

### Including changes on associations

```ruby
class MyModel < ActiveRecord::Base
  audit attributes: [:title, :description], include: [:address]

  has_one :address
end
```

```ruby
# change the address ...

MyModel.first.audit_trail #=>
#   [
# ...
#     {
#       date: <date of change>,
#       action: <:create, :update, or :destroy>,
#       user: <user>,
#       association: :address,
#       changes: {
#         city: {
#           old: <previous_city>,
#           new: <new_city>
#         }
#       }
#     }
#   ]
```
