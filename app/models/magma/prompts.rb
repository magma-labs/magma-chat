module Magma
  module Prompts
    extend self

    # e.g. get("chat.prompt", "hello") => "What do you think about hello?"
    def get(key, *args)
      # todo: cache this
      # todo: allow overriding in database

      # first read the key from a prompts YAML file that lives in config/prompts.yml
      prompts_file = Rails.root.join('config', 'prompts.yml')
      prompts = YAML.load_file(prompts_file)
      prompt = prompts.dig(*key.split('.'))
      raise "Prompt #{key} not found" if prompt.blank?

      if prompt.is_a?(String)
        prompt % args # interpolate the args into the string
      elsif prompt.is_a?(Hash)
        prompt.with_indifferent_access
      else
        prompt
      end
    end
  end
end
