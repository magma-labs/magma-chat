class Bot < ApplicationRecord
  has_many :chats, dependent: :nullify

  def image_url
    "https://robohash.org/#{name}.png?size=640x640&set=set1"
  end

  def self.default
    where(name: "GPT Assistant").first_or_create do |bot|
      bot.directive = "You are a smart and friendly general purpose chatbot."
      bot.description = "A friendly bot that helps you get things done."
      bot.auto_archive_mins = 0
    end
  end

  def self.others
    where.not(id: default.id).order(:name)
  end
end
