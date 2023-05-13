module MessageAnnotator
  extend self



  def self.add_relevant_messages_to(conversation, transcript)
    return if conversation.tags.empty?

    # no need to grab messages that are already in the transcript
    filter = "NOT conversation_id:#{conversation.id}"

    Marqo.client.search(:messages, conversation.tags.to_sentence, filter: filter, limit: 10).then do |result|
      return if result.hits.empty?
      content = [Magma::Prompts.get("message_annotator.system")]
      result.hits.each do |hit|
        next if hit._score < 0.8 # todo: make configurable
        conversation = Conversation.find_by(id: hit.conversation_id)
        next if conversation.nil?
        content << Magma::Prompts.get("message_annotator.line", label: conversation.label, sender_name: hit["sender_name"], content: hit["content"])
      end
      transcript << { role: "user", content: content.join("\n") }
    end
  end
end
