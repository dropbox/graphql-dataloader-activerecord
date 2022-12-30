# frozen_string_literal: true

module DataloaderRelationProxy
  # Wraps ActiveRecord records and provides accessors for
  # loading relationships via GraphQL::Dataloader
  class Record < Object
    delegate :to_param, to: :@object

    def initialize(object, dataloader)
      @object = object
      @dataloader = dataloader
    end

    # Allows comparison with other wrappers or their underlying objects
    #
    # @param [DataloaderRelationProxy::Record] other wrapper or model instance
    def ==(other)
      if other.is_a?(DataloaderRelationProxy::Record)
        comparator = other.instance_variable_get(:@object)
      else
        comparator = other
      end

      @object.send(:==, comparator)
    end

    def is_a?(thing)
      super || @object.send(:is_a?, thing)
    end

    def loaded?
      true
    end
  end
end
