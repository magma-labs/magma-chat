module Vectorable
  extend ActiveSupport::Concern

  # TODO: Make the implementation used here configurable
  # for use with other vector databases such as PgVector, Faiss or Pinecone

  included do
    after_commit :store_vector, on: %i[create update]
    after_commit :delete_vector, on: %i[destroy]
  end

  ##
  # Save a copy of `vector_fields` to the vector database
  def store_vector
    raise ArgumentError.new("Can't store unsaved object") unless persisted?
    primitive_hash?(vector_fields)
    Marqo.client.store(
      index: self.class.table_name, id: id, doc: vector_fields,
      non_tensor_fields: non_tensor_fields
    )
  rescue => e
    Rails.logger.error("Failed to store vector for thought #{id}")
    Rails.logger.error(e)
  end

  ##
  # Delete the associated vector from the database
  def delete_vector
    raise ArgumentError.new("Not deleting live vectorable object") unless destroyed?
    Marqo.client.delete(self.class.table_name, id)
  rescue
    Rails.logger.error("Failed to delete vector for thought #{id}")
  end

  ##
  # Override this method in your model to return an array of fields that
  # should be searchable via plain-text or used in filters
  # For example: `[:type, :bot_id, :subject_id, :subject_type, :importance]`
  def non_tensor_fields
    raise NotImplementedError
  end

  ##
  # Override this method in your model to return the fields that
  # should be used to create the vector as a one-level deep hash
  # with symbolized keys and primitive values (string, numeric, boolean, etc)
  # For example: `content.merge(attributes.symbolize_keys.slice(:type, :brief, :bot_id))`
  def vector_fields
    raise NotImplementedError
  end

  private

  def primitive_hash?(input)
    raise ArgumentError.new("Expected a Hash") unless input.is_a?(Hash)

    input.each_value do |value|
      if value.is_a?(Hash) || value.is_a?(Array)
        raise ArgumentError.new("Hash values should be primitive")
      end
    end

    true
  end

end
