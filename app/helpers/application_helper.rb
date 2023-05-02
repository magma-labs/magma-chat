module ApplicationHelper
  def current_language
    current_user && current_user.preferred_language || "English"
  end

  def count_to_em(count)
    Math.log(count + 1, 10).round(3) * 10
  end

  def markdown(text)
    options = [:hard_wrap, :autolink, :no_intra_emphasis, :fenced_code_blocks]
    tag.div(Markdown.new(text.to_s, *options).to_html.gsub(/<p><\/p>/, '').html_safe, class: "markdown max-w-full")
  end
end
