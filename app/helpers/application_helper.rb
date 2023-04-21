module ApplicationHelper
  def current_language
    current_user && current_user.settings.preferred_language || "English"
  end

  def count_to_em(count)
    Math.log(count + 1, 10).round(3) * 10
  end

  def markdown(text)
    options = [:hard_wrap, :autolink, :no_intra_emphasis, :fenced_code_blocks]
    tag.div(Markdown.new(text.to_s, *options).to_html.gsub(/<p><\/p>/, '').html_safe, class: "markdown max-w-full")
  end

  # proxy to Gpt.t
  def dynamic_copy(prompt, classes: "", max_length: 200, temperature: 1)
    Rails.cache.fetch("dynamic_text_#{prompt}_#{current_language}_#{max_length}_#{temperature}", expires_in: 1.year) do
      Gpt.chat(
        directive: "You are not a helper anymmore, you are now a reliable translation web service.",
        prompt: Prompts.get("dynamic_text", t: prompt, l: current_language), temperature: temperature
      )
    end.then do |text|
      text.gsub!(/^"+|"+$/, '')
      if classes.present?
        tag.div(text, class: "dynamic-text #{classes}")
      else
        text
      end
    end
  end

  def d(text)
    return "" if text.blank?
    return text if current_language == "English"
    dynamic_copy(text).gsub(/\./, '')
  end
end
