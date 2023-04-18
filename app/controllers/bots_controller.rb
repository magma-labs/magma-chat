class BotsController < AdminController
  before_action :set_bot, except: [:index, :new, :create]

  def index
    @bots = [ new_bot ]
    @bots += Bot.all
  end

  def new
    @bot = new_bot
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

  private

  def bot_params
    params.require(:bot).permit(:name, :description, :directive, :auto_archive_mins)
  end

  def set_bot
    @bot = Bot.find(params[:id])
  end

  def new_bot
    Bot.new(id: "new", name: "New Bot", description: "Create a new bot from scratch")
  end
end
