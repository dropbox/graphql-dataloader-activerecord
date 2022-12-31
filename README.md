# graphql-dataloader-activerecord

This gem provides proxy objects in place of ActiveRecord objects where the
proxy handles relationship loading through GraphQL::Dataloader. This is an
experimental approach which should theoretically allow authors to write GraphQL
code that relies on ActiveRecord using regular ActiveRecord relationship
methods without generating N+1 query situations.

## Usage

By including DataloaderRelationProxy::Lazy, your ActiveRecord-based type
classes can transparently use efficient Dataloaders. For example, in the
following example, N stories, and their authors can be authorized and loaded in
a constant number of queries without changing the implementation of the types:

```ruby
class Query < GraphQL::Schema::Object
  field :stories, ['Types::Story']

  def stories
    ::Story.all
  end
end

class Story < GraphQL::Schema::Object
  include DataloaderRelationProxy::Lazy

  field :author, Types::User
  field :text, String

  def self.authorized?(object, context)
    # Even though it looks like we're loading the author here, object.author is
    # actually spawning a new fiber and yielding back to the GraphQL engine.
    # The return value is also chainable so we can continue to efficiently follow
    # ActiveRecord relationships as shown:
    return false unless object.author.plan.name == 'paid'

    # Arbitrary rule to force publication to load to demonstrate this
    # functionality
    return object.publication.present?
  end

  # There is no need to define an `author` method here since @object responds
  # to `author` already, but if we did, it would be:
  def author
    @object.author
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake spec` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and the created tag, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Please begin by filling out the contributor form and asserting that

> The code I'm contributing is mine, and I have the right to license it. I'm
> granting you a license to distribute said code under the terms of this
> agreement. at this page: https://opensource.dropbox.com/cla/

Then create a new pull request through the github interface

## License

Copyright (c) 2022 Dropbox, Inc.

Licensed under the Apache License, Version 2.0 (the "License"); you may not use
this file except in compliance with the License. You may obtain a copy of the
License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed
under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
CONDITIONS OF ANY KIND, either express or implied. See the License for the
specific language governing permissions and limitations under the License.
