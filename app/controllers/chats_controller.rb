class ChatsController < ApplicationController
  # send not found to new
  before_action :require_user, except: [:readonly]
  before_action :load_chat, only: [:show]
  before_action :load_latest_chats, except: [:readonly]

  rescue_from ActiveRecord::RecordNotFound, with: :index

  def index
    @chats ||= current_user.chats.order("updated_at DESC")
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
    @search = ChatSearch.tensor(params[:q])
  end

  def tag
    # todo: add user scoping as filter
    @search = ChatSearch.tag(params[:q])
    render :search
  end

  def show
    if @chat.id != params[:id]
      redirect_to [@chat]
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

  def load_chat
    @chat ||= current_user.chats.find(params[:id])
  end

  def load_latest_chats
    @latest_chats = current_user.chats.order(updated_at: :desc)
    if @chat
      @latest_chats = @latest_chats.where.not(id: @chat.id)
    end
    @latest_chats = @latest_chats.limit(10)
  end
end
