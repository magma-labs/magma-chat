class ApplicationRecord < ActiveRecord::Base
  include CableReady::Broadcaster
  include CableReady::Updatable

  primary_abstract_class

  scope :latest, -> { order(created_at: :desc) }
  scope :last_updated, -> { order(updated_at: :desc) }

  ## adds reader and writer methods (e.g. {attr_name}_text) that auto convert from plain text to array
  def self.list_to_text(attr_name)
    define_method("#{attr_name}_text") do
      send(attr_name).join("\n\n")
    end

    define_method("#{attr_name}_text=") do |value|
      send("#{attr_name}=", value.to_s.strip.split(/\n\n+/).reject(&:blank?))
    end
  end
end
