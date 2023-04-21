module SettingsHelper
  def hello_in_user_language
    if current_user
      Gpt.magic(
        signature: "hello_in(lang)",
        description: "Returns most common way to informally say hello in language supplied. No need for double quotes.",
        args: [current_language]
      ).gsub(/^"+|"+$/, '')
    else
      "Hello"
    end
  end
end
