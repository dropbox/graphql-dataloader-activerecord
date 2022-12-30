# frozen_string_literal: true

module DataloaderRelationProxy
  # Dataloader that loads ActiveRecord objects by an arbitrary key
  class ActiveRecordObject < GraphQL::Dataloader::Source
    def initialize(model_class, key = :id)
      super()
      @model_class = model_class
      @key = key
    end

    def fetch(ids)
      records = @model_class.where(@key => ids)
      by_id = records.index_by { |record| record.send(@key) }
      ids.map { |id| by_id[id] }
    end
  end
end
