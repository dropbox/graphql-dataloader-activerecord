# frozen_string_literal: true

require 'pry'
require 'dataloader_relation_proxy'
require_relative 'model_fixtures'
require_relative 'test_implementation/test_implementation_schema'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
