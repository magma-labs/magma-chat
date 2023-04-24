require 'httparty'

class Marqo
  include HTTParty

  base_uri ENV.fetch('MARQO_URL', "http://localhost:8882")

  class SearchResult < RecursiveOpenStruct
  end

  # TODO: Add a way to pass in auth
  def initialize(auth = { username: 'admin', password: 'admin' })
    @auth = auth
  end

  def store(index:, doc:, id:, non_tensor_fields: [])
    return if ENV['MARQO_URL'].blank?
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
      response.dig("items",0,"_id")
    end
  end

  def search(index_name, query, filter: nil, limit: 5)
    puts
    puts "🔍🔍🔍 #{index_name} 🔍🔍🔍"
    puts "🔍🔍🔍 #{query} 🔍🔍🔍"
    puts "🔍🔍🔍 #{filter} 🔍🔍🔍"
    puts
    options = {
      basic_auth: @auth,
      headers: { 'Content-Type' => 'application/json' },
      body: {
        q: query,
        filter: filter,
        searchMethod: "TENSOR",
        limit: limit
      }.to_json
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
