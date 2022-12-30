# frozen_string_literal: true

require 'active_record'
require 'graphql'
require 'active_support/core_ext/module/delegation'
require_relative 'dataloader_relation_proxy/collection'
require_relative 'dataloader_relation_proxy/record'
require_relative 'dataloader_relation_proxy/version'
require_relative 'dataloader_relation_proxy/active_record_object'

# Top level namespace for a system that proxies activerecord relationships
# through GraphQL dataloaders.
module DataloaderRelationProxy
  # Namespace to house the proxy classes so they are easily addressable
  Proxies = Module.new

  Error = Class.new(StandardError)

  DELEGATE_TO_MODEL_METHODS = %i[
    ===
    ==
    eql?
    equal?
    <=>
    <
    >
    <=
    >=
  ].freeze

  @defined = Set.new

  # Defines a wrapper class for the provided model. This wrapper creates
  # classes that extend DataloaderRelationProxy::Record and then defines
  # relationship accessors that are efficiently batched by GraphQL::Dataloader.
  #
  # @param [Class]
  def self.define_for!(model)
    @defined << model

    # Recursively define the namespace and wrapper class
    klass = model.name.split('::').reduce(Proxies) do |memo, value|
      next memo.const_get(value, false) if memo.const_defined?(value, false)

      memo.const_set(value, Class.new(DataloaderRelationProxy::Record))
    end

    define_belongs_to_accessors!(klass, model)
    define_has_many_accessors!(klass, model)
    delegate_class_methods!(klass, model)
    catch_remaining_methods!(klass)
  end

  # Determine if there is already a wrapper class defined for the given model.
  #
  # @param [Class]
  def self.defined_for?(model)
    @defined.include?(model)
  end

  # Ensure a wrapper class is defined for the given model and return it.
  #
  # @param [Class]
  def self.for(model)
    define_for!(model) unless defined_for?(model)

    DataloaderRelationProxy::Proxies.const_get(model.name, false)
  end

  # Given an activerecord model and wrapper class, define an accessor on the
  # wrapper class for each belongs_to relationship on the model driven by
  # GraphQL::Datalaoder.
  #
  # @param [DataloaderRelationProxy::Record] wrapper class to define
  #   accessors
  # @param [Class] underlying model
  def self.define_belongs_to_accessors!(klass, model)
    return unless model.respond_to?(:reflect_on_all_associations)

    model.reflect_on_all_associations(:belongs_to).each do |reflection|
      # not sure how to handle this yet
      next if reflection.polymorphic?

      self.for(reflection.klass)

      klass.instance_eval do
        DataloaderRelationProxy.activerecord_belongs_to(klass, reflection)
      end
    end
  end

  # Given an activerecord model and wrapper class, define an accessor on the
  # wrapper class for each has_many relationship on the model driven by
  # GraphQL::Datalaoder.
  #
  # @param [DataloaderRelationProxy::Record] wrapper class to define
  #   accessors
  # @param [Class] underlying model
  def self.define_has_many_accessors!(klass, model)
    return unless model.respond_to?(:reflect_on_all_associations)

    model.reflect_on_all_associations(:has_many).each do |reflection|
      # not sure how to handle this yet
      next if reflection.polymorphic?

      klass.instance_eval do
        DataloaderRelationProxy.activerecord_has_many(klass, reflection)
      end
    end
  end

  # Delegates some class methods to the underlying model class so that
  # instances of this proxy can more readily stand in for a model instance.
  #
  # @param [DataloaderRelationProxy::Record] proxy class
  # @param [Class] underlying model
  def self.delegate_class_methods!(klass, model)
    DELEGATE_TO_MODEL_METHODS.each do |m|
      klass.define_singleton_method(m) do |other|
        model.send(m, other)
      end
    end
  end

  # rubocop:disable Metrics/MethodLength
  def self.catch_remaining_methods!(klass)
    klass.instance_eval do
      define_method(:method_missing) do |method_name, *args, &block|
        raise NoMethodError, "Missing method '#{method_name}' on #{@object}" unless @object.respond_to?(method_name)

        self.class.instance_eval do
          delegate method_name, to: :@object
        end

        @object.send(method_name, *args, &block)
      end

      define_method(:respond_to_missing?) do |method_name, include_private = false|
        @object.respond_to?(method_name) || super(method_name, include_private)
      end
    end
  end
  # rubocop:enable Metrics/MethodLength

  # Define a getter that works something like an ActiveRecord belongs_to
  # relationship, except using a dataloader.
  def self.activerecord_belongs_to(klass, reflection)
    klass.define_method(reflection.name) do
      instance = @dataloader.with(
        ActiveRecordObject,
        reflection.klass,
        reflection.association_primary_key
      ).load(@object.send(reflection.foreign_key))
      return nil if instance.nil?

      DataloaderRelationProxy.for(instance.class).new(instance, @dataloader)
    end
  end

  # Define a getter that works something like an ActiveRecord has_many
  # relationship, except using a dataloader.
  def self.activerecord_has_many(klass, reflection)
    klass.define_method(reflection.name) do
      Collection.new(@object.send(reflection.name), @dataloader)
    end
  end
end
