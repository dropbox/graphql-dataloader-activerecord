# frozen_string_literal: true

module Types
  class Query < GraphQL::Schema::Object
    field :stories, ['Types::Story']

    def stories
      ::Story.all
    end
  end

  class User < GraphQL::Schema::Object
    field :name, String
  end

  class Story < GraphQL::Schema::Object
    include DataloaderRelationProxy::Lazy

    def self.authorized?(object, *)
      # force the author to load for testing purposes
      object.author.present?

      # Arbitrary rule to force publication to load
      ['Fresno Bee', 'Miami Herald'].include?(object.publication.name)
    end

    field :author, Types::User
    field :text, String
  end
end

class TestImplementationSchema < GraphQL::Schema
  query Types::Query
  use GraphQL::Dataloader
end
