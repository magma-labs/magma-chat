class SearchLongTermMemory < BotTool
  def perform(chat, params)
    question = params[:question]
    puts
    puts "🤖🤖🤖 SearchLongTermMemory: #{question} 🤖🤖🤖"
    puts
    Marqo.client.search("thoughts", question, limit: 5).then do |response|
      puts
      puts "💾💾💾 SearchLongTermMemory: response: #{response} 💾💾💾"
      puts
      # todo: chat.prompt with response
    end
  end
end
