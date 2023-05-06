class ConversationsController < ApplicationController
  # send not found to new
  before_action :require_user, except: [:show, :readonly]
  before_action :load_latest_conversations, except: [:show, :readonly]

  rescue_from ActiveRecord::RecordNotFound, with: :index

  def index
    @conversations ||= current_user.conversations.order("updated_at DESC")
    if @conversations.empty?
      redirect_to new_conversation_path
    end
  end

  def new
    @conversation = current_user.conversations.new
  end

  def create
    current_user.conversations.create!(conversation_params).then do |conversation|
      redirect_to [conversation]
    end
  end

  def search
    # todo: add user scoping as filter
    @search = ConversationSearch.message_content(current_user, params[:q])
  end

  def tag
    # todo: add user scoping as filter
    @search = ConversationSearch.tag(params[:q])
    render :search
  end

  def show
    if current_user
      if current_admin?
        @conversation ||= Conversation.find(params[:id])
      else
        @conversation ||= current_user.conversations.find(params[:id])
      end
      if @conversation.id != params[:id]
        return redirect_to [@conversation]
      end
      load_latest_conversations
    else
      Conversation.find(params[:id]).then do |conversation|
        if conversation.public_access?
          redirect_to readonly_path(conversation)
        else
          redirect_to root_path, notice: "Conversation not found"
        end
      end
    end
  end

  def readonly
    @conversation = Conversation.find(params[:id])
    if @conversation.public_access?
      render :show
    else
      redirect_to root_path, notice: "Conversation not found"
    end
  end

  def tts
    message = Message.find(params[:message_id])
    bot = message.conversation.bot
    Eleven.tts(text: message.content, stability: bot.voice_stability, voice_id: bot.voice_id).then do |response|
      # send MP3 data to browser with filename
      audio =  response.read_body
      send_data audio, type: "audio/mpeg", disposition: "inline", filename: "message-#{message.id}.mp3"
    end
  end

  private

  def conversation_params
    params.require(:conversation).permit(:first_message, :bot_id).to_h
  end


end
