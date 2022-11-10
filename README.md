# Oa ![test](https://github.com/uiur/oa/actions/workflows/main.yml/badge.svg)

Oa lets you write OpenAPI annotations in your API code.

```ruby
class UsersController
  include Oa::Annotator

  openapi do
    {
      '/users' => {
        get: {
          responses: {
            # ...
          }
        }
      }
    }
  end
  def index
    # ...
  end

  openapi do
    # You can write any code here, as long as the block returns result as hash.
    {
      '/users/{id}' => {
        get: {
          parameters: [
            # ...
          ],
          responses: {
            # ...
          }
        }
      }
    }
  end
  def show
    # ...
  end
end

# Put all annotations together and write openapi documents to files
Oa.generate_documents
```

## On DSL

Oa itself doesn't provide a lot of DSL to describe openapi. Instead, it allows developers to define custom DSL for each application purpose.

Other libraries have lots of DSL methods but it's somewhat hard to master. In many cases, making custom DSL is a better way to write concise openapi spec in Ruby.

```ruby
module DSL
  def get(path, operation)
    {
      path => {
        get: operation
      }
    }
  end
end

Oa.configure do |config|
  config.include DSL
  # ...
end

class UsersController
  include Oa::Annotator

  openapi do
    # So you can write:
    get('/users', {
      # ..
    })
  end
  def index
  end
end
```

## Usage

First, it requires defining at least one document.

If you use Rails, in `config/initializers/oa.rb`:

```ruby
Oa.configure do |config|
  config.documents = [
    Oa::Document.new(
      name: :api,

      # The destination of output openapi document
      path: 'app/openapi/api.yml',

      # openapi metadata. This will be merged into the output openapi document.
      root: {
        openapi: '3.0.0',
        info: {
          title: 'api',
          version: '1.0.0'
        },
      }
    )
  ]
end
```

Second, write some annotations in your controllers:

```ruby
class BaseController
  include Oa::Annotator

  # specify document name in the configuration:
  openapi_document :api
end

class UsersController < BaseController
  openapi do
    {
      '/users' => {
        get: {
          responses: {
            # ...
          }
        }
      }
    }
  end
  def index
    # ...
  end
end
```

And then, you can generate openapi documents:

```ruby
Oa.generate_documents
#=> app/openapi/api.yml
```

## Configuration

### Documents

`config.documents` can have multiple documents.

```ruby
Oa.configure do |config|
  config.documents = [
    Oa::Document.new(
      name: :api,
      path: 'app/openapi/api.yml',
      root: {
        openapi: '3.0.0',
        info: {
          title: 'api',
          version: '1.0.0'
        },
      }
    ),
    Oa::Document.new(
      name: :api2,
      path: 'app/openapi/api2.yml',
      root: {
        openapi: '3.0.0',
        info: {
          title: 'api2',
          version: '1.0.0'
        },
      }
    )
  ]
end
```

So, it can generate seperate document files for each api.

```ruby
class Api::BaseController
  include Oa::Annotator
  openapi_document :api
end

class Api::UsersController < Api::BaseController
  # ...
end

class Api2::BaseController
  include Oa::Annotator
  openapi_document :api2
end

class Api2::UsersController < Api2::BaseController
  # ...
end
```



## Installation

Add this line to your application's Gemfile:

```ruby
gem 'oa', github: 'uiur/oa'
```

And then execute:

    $ bundle install

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/oa. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/oa/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Oa project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/oa/blob/main/CODE_OF_CONDUCT.md).
