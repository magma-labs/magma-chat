class ApplicationJob < ActiveJob::Base
  include CableReady::Broadcaster

  # Automatically retry jobs that encountered a deadlock
  retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  discard_on ActiveJob::DeserializationError

  protected

  # todo: move this to a helper
  def extract_json(text)
    start_index = text.index('{')
    return nil if start_index.nil?

    end_index = start_index
    brace_count = 1

    text[start_index + 1..-1].each_char.with_index do |char, index|
      brace_count += 1 if char == '{'
      brace_count -= 1 if char == '}'
      end_index += 1
      break if brace_count.zero?
    end

    text[start_index..end_index]
  end

end
