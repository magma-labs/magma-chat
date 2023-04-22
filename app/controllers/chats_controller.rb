class ChatsController < ApplicationController
  # send not found to new
  before_action :require_user, except: [:show, :readonly]
  before_action :load_latest_chats, except: [:show, :readonly]

  rescue_from ActiveRecord::RecordNotFound, with: :index

  def index
    @chats ||= current_user.chats.order("updated_at DESC")
    if @chats.empty?
      redirect_to new_chat_path
    end
  end

  def new
    @chat = current_user.chats.new
  end

  def create
    current_user.chats.create!(chat_params).then do |chat|
      redirect_to [chat]
    end
  end

  def search
    # todo: add user scoping as filter
    @search = ChatSearch.message_content(current_user, params[:q])
  end

  def tag
    # todo: add user scoping as filter
    @search = ChatSearch.tag(params[:q])
    render :search
  end

  def show
    if current_user
      if current_admin?
        @chat ||= Chat.find(params[:id])
      else
        @chat ||= current_user.chats.find(params[:id])
      end
      if @chat.id != params[:id]
        return redirect_to [@chat]
      end
      load_latest_chats
    else
      Chat.find(params[:id]).then do |chat|
        if chat.public_access?
          redirect_to readonly_path(chat)
        else
          redirect_to root_path, notice: "Chat not found"
        end
      end
    end
  end

  def readonly
    @chat = Chat.find(params[:id])
    if @chat.public_access?
      render :show
    else
      redirect_to root_path, notice: "Chat not found"
    end
  end

  private

  def chat_params
    params.require(:chat).permit(:first_message, :engine, :bot_id)
  end


end
