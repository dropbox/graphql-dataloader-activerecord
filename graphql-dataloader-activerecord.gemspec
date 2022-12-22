# frozen_string_literal: true

require_relative "lib/graphql/dataloader/active_record/version"

Gem::Specification.new do |spec|
  spec.name = "graphql-dataloader-activerecord"
  spec.version = GraphQL::Dataloader::ActiveRecord::VERSION
  spec.authors = ["Stephen Crosby"]
  spec.email = ["stevecrozz@dropbox.com"]

  spec.summary = "Prevent ActiveRecord N+1 queries within GraphQL"
  spec.description = <<~DESCRIPTION
    This gem provides proxy objects in place of ActiveRecord objects where the
    proxy handles relationship loading through GraphQL::Dataloader. This is an
    experimental approach which should theoretically allow authors to write GraphQL
    code that relies on ActiveRecord using regular ActiveRecord relationship
    methods without generating N+1 query situations.
  DESCRIPTION
  spec.homepage = "https://github.com/dropbox/graphql-dataloader-activerecord"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git))})
    end
  end
  spec.require_paths = ["lib"]
end
