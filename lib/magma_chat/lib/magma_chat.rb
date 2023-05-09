require 'rails'
require_relative 'magma_chat/version'
require_relative 'magma_chat/railtie'

module MagmaChat
  BASE_PATH = './lib/magma_chat/lib/magma_chat/'

  autoload :Bot,            "#{BASE_PATH}app/models/bot"
  autoload :Settings,       "#{BASE_PATH}app/models/concerns/settings"
  autoload :UsedAsSubject,  "#{BASE_PATH}app/models/concerns/used_as_subject"
end
