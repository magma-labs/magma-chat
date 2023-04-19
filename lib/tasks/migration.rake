namespace :migrate do
  desc "Migrate transcripts to messages"
  task transcripts_to_messages: :environment do
    Message.delete_all
    Message.transaction do
      last_message = nil # we will capture for setting the timestamps on assistant messages
      counter = 1
      Chat.find_each do |chat|
        chat.transcript.each do |data|
          data.symbolize_keys!
          message = chat.messages.build(role: data[:role], content: data[:content])
          if data[:role] == "user"
            message.sender = chat.user
          else
            message.sender = chat.bot
          end
          message.created_at = Time.at(data[:timestamp] || last_message&.created_at&.to_i || chat.created_at.to_i + counter)
          message.updated_at = Time.at(data[:timestamp] || last_message&.updated_at&.to_i || chat.created_at.to_i + counter)
          message.save!

          last_message = message
          counter += 1
        end
      end
    end
  end
end
