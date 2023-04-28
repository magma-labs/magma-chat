class SettingField
  attr_reader :form
  attr_reader :user
  attr_reader :key
  attr_reader :value

  def initialize(user, form, key, value)
    @form = form
    @user = user
    @key = key
  end

  def label
    form.label(key, Gpt.dt(t[:title]))
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
    user.admin ? :admin : :user
  end
end
