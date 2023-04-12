class ChatsController < ApplicationController
  # send not found to new
  rescue_from ActiveRecord::RecordNotFound, with: :index

  def index
    redirect_to [:new, :chat]
  end

  def create
    Chat.create!(title: chat_params[:first_message], engine: chat_params[:engine]).then do |chat|
      redirect_to [chat]
    end
  end

  def show
    @chat = Chat.find(params[:id])
  end

  private

  def chat_params
    params.require(:chat).permit(:first_message, :engine)
  end
end
