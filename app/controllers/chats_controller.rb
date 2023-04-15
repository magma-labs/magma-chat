class ChatsController < ApplicationController
  # send not found to new
  before_action :require_user
  rescue_from ActiveRecord::RecordNotFound, with: :index


  def index
    @chats ||= current_user.chats.order("updated_at DESC")
  end

  def create
    Chat.create!(title: chat_params[:first_message], engine: chat_params[:engine]).then do |chat|
      redirect_to [chat]
    end
  end

  def show
    @chat ||= Chat.find(params[:id])
    if @chat.id != params[:id]
      redirect_to [@chat]
    end
  end

  private

  def chat_params
    params.require(:chat).permit(:first_message, :engine)
  end
end
