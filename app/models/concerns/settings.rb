module Settings
  include ActiveSupport::Concern

  def settings
    @settings ||= RecursiveOpenStruct.new(begin
      super.then do |hash|
        if hash.kind_of? String
          # TODO: why is this workaround needed sometimes?
          JSON.parse(hash)
        else
          hash
        end
      end
    rescue => exception
      Rails.logger.error("Error loading settings for #{self.class.name} #{self.id}: #{exception.message}")
      {}
    end, recurse_over_arrays: true)
  end

  def raw_settings
    read_attribute(:settings)
  end
end
