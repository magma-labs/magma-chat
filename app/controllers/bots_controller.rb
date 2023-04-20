class BotsController < AdminController
  skip_before_action :verify_authenticity_token, only: [:promote]
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
