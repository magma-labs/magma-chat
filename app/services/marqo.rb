require 'httparty'

##
# A Ruby wrapper for the Marqo API for embedding and later searching bot memories.
# Lexical search works as expected. Tensor search is for sentences and paragraphs
# up to 128 characters. See https://huggingface.co/sentence-transformers/all-MiniLM-L6-v1
# for more information about the embedding model used natively by Marqo.
class Marqo
  include HTTParty

  # Note about settings: We are currently using the default settings for Marqo.
  # But it is possible to change them, including the embedding model, on the fly.
  # https://marqo.pages.dev/0.0.19/API-Reference/settings/
  # TODO: Support for configuring index settings at runtime

  base_uri ENV.fetch('MARQO_URL')

  class IndexNotFound < StandardError
  end

  class SearchResult < RecursiveOpenStruct
  end

  # TODO: Add a way to pass in auth
  def initialize(auth = { username: 'admin', password: 'admin' })
    @auth = auth
  end

  def create(index:, model: "hf/all_datasets_v4_MiniLM-L6")
    puts
    puts "🧠🧠🧠 CREATING INDEX: #{index} 🧠🧠🧠"
    puts
    options = {
      headers: { 'Content-Type' => 'application/json' },
      body: { index_defaults: { model: model } }.to_json
    }
    url = "/indexes/#{index.to_s.parameterize}"
    self.class.post(url, options).then do |response|
      puts response
    end
  end

  def store(index:, doc:, id:, non_tensor_fields: [])
    return if ENV['MARQO_URL'].blank?

    create_index_attempts ||= 0

    puts
    puts "🧠🧠🧠 INDEX: #{index} 🧠🧠🧠"
    puts "🧠🧠🧠 DOC: #{doc} 🧠🧠🧠"
    puts "🧠🧠🧠 ID: #{id} 🧠🧠🧠"
    puts "🧠🧠🧠 NON TENSOR FIELDS: #{non_tensor_fields} 🧠🧠🧠"
    puts
    options = {
      headers: { 'Content-Type' => 'application/json' },
      body: [doc.merge({_id: id})].to_json
    }
    url = "/indexes/#{index.to_s.parameterize}/documents"
    if non_tensor_fields.any?
      field_array = non_tensor_fields.map { |f| "non_tensor_fields=#{f}" }
      url += "?#{field_array.join("&")}"
    end
    self.class.post(url, options).then do |response|
      puts response
      raise IndexNotFound if response["type"].to_s == "invalid_request" && response["code"].to_s == "index_not_found"
      response.dig("items",0,"_id")
    end
  rescue IndexNotFound
    create_index_attempts += 1

    if create_index_attempts < 2
      create(index: index)
      retry
    end
  end

  def search(index_name, query, filter: nil, limit: 5)
    puts
    puts "🔍🔍🔍 #{index_name} 🔍🔍🔍"
    puts "🔍🔍🔍 #{query} 🔍🔍🔍"
    puts "🔍🔍🔍 #{filter} 🔍🔍🔍"
    puts
    params = { q: query, searchMethod: "TENSOR", limit: limit }
    params[:filter] = filter if filter.present?
    options = {
      basic_auth: @auth,
      headers: { 'Content-Type' => 'application/json' },
      body: params.to_json
    }
    response = self.class.post("/indexes/#{index_name.to_s.parameterize}/search", options)
    SearchResult.new(response, recurse_over_arrays: true)
  end

  def lexsearch(index_name, attributes, query)
    options = {
      basic_auth: @auth,
      headers: { 'Content-Type' => 'application/json' },
      body: {
        q: query,
        searchableAttributes: attributes,
        searchMethod: "LEXICAL"
      }.to_json
    }
    SearchResult.new(self.class.post("/indexes/#{index_name.to_s.parameterize}/search", options))
  end

  def delete(index_name, id_or_ids)
    options = {
      basic_auth: @auth,
      headers: { 'Content-Type' => 'application/json' },
      body: [id].flatten.to_json
    }
    self.class.post("/indexes/#{index_name.to_s.parameterize}/documents/delete-batch", options)
  end

  def remove(index_name)
    options = {
      basic_auth: @auth,
      headers: { 'Content-Type' => 'application/json' }
    }
    self.class.delete("/indexes/#{index_name.to_s.parameterize}", options)
  end

  def self.client
    @client ||= new
  end

  private

  def wrap(result)
    RecursiveOpenStruct.new(hash, recurse_over_arrays: true)
  end
end
