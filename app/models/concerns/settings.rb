module Settings
  include ActiveSupport::Concern

  def settings
    RecursiveOpenStruct.new(super, recurse_over_arrays: true)
  end
end
