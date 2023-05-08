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
    form.label(key, I18n.it(t[:title], current_user.preferred_language))
  end

  # This code gets the type of the field, as well as any arguments that should be passed to it.
  # It then processes the arguments, and uses the type and processed arguments to generate the
  # input field with the correct type and arguments.
  def input
    field_type = t.dig(user_type, :field)
    field_args = t.dig(user_type, :field_args)
    processed_field_args = process_field_args(field_args)
    form.send(field_type.to_sym, key, *processed_field_args)
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

  # The process_field_args method takes an array of arguments and processes
  # each one. If an argument is a string that starts with "send:", remove
  # the "send:" prefix and pass the result to the process_send_arg method.
  #
  # If an argument is an array, call the process_field_args method
  # recursively on the array.
  #
  # If an argument is a hash, call the process_field_args method recursively
  # on the hash values and return a new hash with the processed values.
  #
  # If an argument is neither a string nor an array nor a hash, return it
  # unchanged.

  def process_field_args(args)
    args.map do |arg|
      if arg.is_a?(String) && arg.start_with?("send:")
        process_send_arg(arg)
      elsif arg.is_a?(Array)
        process_field_args(arg)
      elsif arg.is_a?(Hash)
        arg.transform_values { |value| process_field_args([value]).first }
      else
        arg
      end
    end
  end

  def process_send_arg(arg)
    # skip the send: prefix before splitting
    method_chain = arg[5..-1].split('.')

    # call each method in the chain, passing the result of the previous call
    method_chain.inject(self) do |current_context, method|
      current_context.public_send(method)
    end
  end
end
