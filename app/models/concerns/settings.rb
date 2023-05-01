module Settings
  include ActiveSupport::Concern

  def settings
    RecursiveOpenStruct.new(super, recurse_over_arrays: true)
  end

  def raw_settings
    read_attribute(:settings)
  end
end
