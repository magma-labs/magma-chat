class ChatsController < ApplicationController
  # send not found to new
  before_action :require_user
  rescue_from ActiveRecord::RecordNotFound, with: :index


  def index
    @chats ||= current_user.chats.order("updated_at DESC")
  end

  def create
    current_user.chats.create!(title: chat_params[:first_message], engine: chat_params[:engine]).then do |chat|
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
    @chat ||= current_user.chats.find(params[:id])
    if @chat.id != params[:id]
      redirect_to [@chat]
    end
  end

  private

  def chat_params
    params.require(:chat).permit(:first_message, :engine)
  end
end
