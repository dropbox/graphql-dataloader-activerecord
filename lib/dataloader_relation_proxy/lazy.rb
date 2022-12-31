# frozen_string_literal: true

module DataloaderRelationProxy
  # Including Lazy causes two changes for type classes.
  #
  # 1) Type.authorized? receives a relationship proxy object rather than the
  #   actual object as its first parameter.
  # 2) Type#rel is provided so that type instances can easily build and access
  #   a relationship proxy.
  #
  # @see DataloaderRelationProxy for information about what benefits are
  #   provided
  module Lazy
    extend ActiveSupport::Concern

    # Prepended to type classes in order to change the authorized? interface
    module Authorizer
      def authorized?(object, context)
        if object.is_a?(DataloaderRelationProxy)
          super(object, context)
        else
          super(DataloaderRelationProxy.for(object.class).new(object, context.dataloader), context)
        end
      end
    end

    included do |parent|
      parent.singleton_class.prepend(Authorizer)
    end

    def object
      if @object.is_a?(DataloaderRelationProxy)
        @object
      else
        DataloaderRelationProxy.for(@object.class).new(@object, context.dataloader)
      end
    end
  end
end
