class BotsController < AdminController
  before_action :set_bot, except: [:index, :new, :create]

  def index
    @bots = [ new_bot ]
    @bots += Bot.all
  end

  def new
    @bot = Bot.new
  end

  def create
    Bot.create!(bot_params).then do |bot|
      redirect_to [bot]
    end
  end

  def update
    Bot.find(params[:id]).then do |bot|
      bot.update!(bot_params)
      redirect_to [bot]
    end
  end

  def destroy
    Bot.find(params[:id]).then do |bot|
      if bot.chats.any?
        redirect_to bot_path(bot), alert: "Cannot delete bot with chats"
      else
        bot.destroy!
        redirect_to bots_path
      end
    end
  end

  private

  def bot_params
    params.require(:bot).permit(:name, :role, :image_url, :intro, :directive, :goals_text, :auto_archive_mins)
  end

  def set_bot
    @bot = Bot.find(params[:id])
  end

  def new_bot
    Bot.new(id: "new", name: "New Bot", intro: "Create a new bot from scratch")
  end
end
