# frozen_string_literal: true

class SettingsReflex < ApplicationReflex
  def change(gid, name, value)
    puts "🥳🥳🥳🥳🥳🥳🥳🥳🥳🥳"
    puts "SettingsReflex#change"
    puts "gid: #{gid}"
    puts "name: #{name}"
    puts "value: #{value}"
    puts
    entity = GlobalID::Locator.locate(gid)
    entity.update!(name => value)
  end
end
