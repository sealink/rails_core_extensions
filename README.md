# Rails Core Extensions

[![Build Status](https://github.com/sealink/rails_core_extensions/workflows/Build%20and%20Test/badge.svg?branch=master)](https://github.com/sealink/rails_core_extensions/actions)
[![Coverage Status](https://coveralls.io/repos/sealink/rails_core_extensions/badge.png)](https://coveralls.io/r/sealink/rails_core_extensions)
[![Code Climate](https://codeclimate.com/github/sealink/rails_core_extensions.png)](https://codeclimate.com/github/sealink/rails_core_extensions)

# DESCRIPTION

Extends the core rails classes with helpful functions

# INSTALLATION

Add to your Gemfile:
gem 'rails_core_extensions'

This gems contains many extensions including a sort extension:

Sortable

This allows you to sort an entire collection by setting the new position of an item
and all other items will reorganise as needed.

```ruby
app/controllers/types_controller.rb
class TypesController < ActionController::Base
  sortable
end

config/routes.rb

In Rails 6:
resources :types do
  collection
    post :sort
  end
end
```

You need to submit a collection of objects named the same as the controller.

e.g. for the above the params should be:

```ruby
types_body[]=1
types_body[]=3
```

Where the value is the id, and the position of submission is the new order, e.g.
In the above, the item of id 3 will be updated to position 2

If you have scoped sorts, e.g. sorts within categories you also need to pass in 2 params:

- scope (e.g. category_id)
- a variable by that name, e.g. category_id

So in the above if you want to upgrade category_id 6, you could submit
scope=category_id&category_id=6

along with type_body[]=7.. for all the types in category 6

# RELEASE

To publish a new version of this gem the following steps must be taken.

- Update the version in the following files
  ```
    CHANGELOG.md
    lib/rails_core_extensions/version.rb
  ```
- Create a tag using the format v0.1.0
- Follow build progress in GitHub actions
