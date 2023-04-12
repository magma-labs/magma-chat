module ApplicationHelper
  def markdown(text)
    options = [:hard_wrap, :autolink, :no_intra_emphasis, :fenced_code_blocks]
    tag.div(Markdown.new(text.to_s, *options).to_html.gsub(/<p><\/p>/, '').html_safe, class: "markdown max-w-full")
  end
end
