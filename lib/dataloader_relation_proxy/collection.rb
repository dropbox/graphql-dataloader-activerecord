# frozen_string_literal: true

module DataloaderRelationProxy
  # Represents an ActiveRecord collection and provides an enumerable that
  # returns underlying objects that are instances of
  # DataloaderRelationProxy::Record
  class Collection < Object
    def initialize(object, dataloader)
      @object = object
      @dataloader = dataloader

      # Need to ensure the collection elements are wrapped in
      # DataloaderRelationProxy objects. I'm sure there's a nicer alternative.
      #
      # rubocop:disable Lint/NestedMethodDefinition
      def @object.load_target
        @association.load_target.map do |record|
          DataloaderRelationProxy.for(record.class).new(record, @dataloader)
        end
      end
      # rubocop:enable Lint/NestedMethodDefinition
    end

    def method_missing(method_name, *args, &block)
      raise NoMethodError, "Missing method '#{method_name}' on #{@object}" unless @object.respond_to?(method_name)

      result = @object.send(method_name, *args, &block)
      if result.is_a?(ActiveRecord::Base)
        DataloaderRelationProxy.for(result.class).new(result, @dataloader)
      else
        result
      end
    end

    def respond_to_missing?(method_name, _include_private = false)
      @object.respond_to?(method_name)
    end

    def loaded?
      true
    end
  end
end
