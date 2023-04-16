require 'httparty'

class Marqo
  include HTTParty

  base_uri 'http://localhost:8882'

  def initialize(auth = { username: 'admin', password: 'admin' })
    @auth = auth
  end

  def store(index:, doc:, id:, non_tensor_fields: [])
    options = {
      headers: { 'Content-Type' => 'application/json' },
      body: [doc.merge({_id: id})].to_json
    }
    url = "/indexes/#{index.parameterize}/documents"
    if non_tensor_fields.any?
      field_array = non_tensor_fields.map { |f| "non_tensor_fields=#{f}" }
      url += "?#{field_array.join("&")}"
    end
    self.class.post(url, options).then do |response|
      puts response
      response.dig("items",0,"_id")
    end
  end

  def search(index_name, query, limit: 5)
    options = {
      basic_auth: @auth,
      headers: { 'Content-Type' => 'application/json' },
      body: { q: query, limit: limit }.to_json
    }
    self.class.post("/indexes/#{index_name.parameterize}/search", options)
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
    self.class.post("/indexes/#{index_name.parameterize}/search", options)
  end

  def delete(index_name, id)
    options = {
      basic_auth: @auth,
      headers: { 'Content-Type' => 'application/json' },
      body: { ids: [id].flatten }.to_json
    }
    self.class.post("/indexes/#{index_name.parameterize}/documents/delete-batch", options)
  end

  def remove(index_name)
    options = {
      basic_auth: @auth,
      headers: { 'Content-Type' => 'application/json' }
    }
    self.class.delete("/indexes/#{index_name.parameterize}", options)
  end

  def self.client
    @client ||= new
  end
end
