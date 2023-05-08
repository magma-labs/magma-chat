require_relative 'lib/magma_chat/lib/magma_chat/version'

Gem::Specification.new do |spec|
  spec.name        = 'magma_chat'
  spec.version     = MagmaChat::VERSION
  spec.authors     = ['MagmaLabs']
  spec.email       = ['developer@magmalabs.io']
  spec.homepage    = 'https://github.com/magma-labs/magma-chat'
  spec.summary     = 'ChatGPT-style interface for GPT'
  spec.description = 'MagmaLabs presents the best ChatGPT-style interface for GPT, written in Rails 7 with CableReady and StimulusReflex!'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/magma-labs/magma-chat'
  spec.metadata['changelog_uri'] = 'https://github.com/magma-labs/magma-chat/CHANGELOG.md'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["lib/magma_chat/{app,config,db,lib}/**/*", 'LICENSE', 'Rakefile', 'README.md']
  end
end
