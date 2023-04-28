class SettingField
  include ApplicationHelper

  attr_reader :form
  attr_reader :current_user
  attr_reader :key
  attr_reader :value

  def initialize(current_user, form, key, value)
    @form = form
    @current_user = current_user
    @key = key
  end

  def label
    form.label(key, d(t[:title]))
  end

  def input
    field_type = t.dig(user_type, :field)
    field_args = t.dig(user_type, :field_args)
    form.send(field_type, key, *field_args)
  end

  def wrapper_class
    t[:wrapper_class] || "flex flex-col gap-1"
  end

  private

  def t
    @opts ||= I18n.t(key, scope: "settings")
  end

  def user_type
    current_user.admin ? :admin : :user
  end
end
