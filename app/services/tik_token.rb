require 'tiktoken_ruby'

module TikToken
  extend self

  DEFAULT_MODEL = "gpt-3.5-turbo"

  def count(string, model: DEFAULT_MODEL)
    get_tokens(string, model: model).length
  rescue
    (string.length * 0.75).to_i
  end

  def get_tokens(string, model: DEFAULT_MODEL)
    encoding = Tiktoken.encoding_for_model(model)
    tokens = encoding.encode(string)
    tokens.map do |token|
      [token, encoding.decode([token])]
    end.to_h
  end
end
