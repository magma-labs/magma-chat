module Settings
  extend ActiveSupport::Concern

  included do
    after_initialize :initialize_settings

    settings_config.each_key do |key|
      default = settings_config.dig(key, :default)

      define_method(key) do
        val = self.settings[key]
        val.nil? ? default : val
      end

      if [TrueClass, FalseClass].include? default.class
        define_method("#{key}?") do
          val = ActiveRecord::Type::Boolean.new.cast(self.settings[key])
          val.nil? ? default : val
        end
      end

      define_method("#{key}=") do |value|
        case default
        when TrueClass, FalseClass
          self.settings[key] = ActiveRecord::Type::Boolean.new.cast(value)
        when Integer
          self.settings[key] = value.to_i
        when Float
          self.settings[key] = value.to_f
        else
          self.settings[key] = value
        end
      end
    end
  end

  def initialize_settings
    # todo: why needed on Rails 7.1
    if settings.is_a? String
      self.settings = JSON.parse(settings, symbolize_names: true)
    end
  end

  def settings
    read_attribute(:settings).tap do |s|
      s.deep_symbolize_keys! if s.is_a? Hash
    end
  end

end
