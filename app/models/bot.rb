# == Schema Information
#
# Table name: bots
#
#  id                :uuid             not null, primary key
#  auto_archive_mins :integer          default(0), not null
#  chats_count       :integer          default(0), not null
#  directive         :text             default(""), not null
#  goals             :jsonb            not null
#  image_url         :string
#  intro             :text
#  name              :string           not null
#  properties        :jsonb            not null
#  role              :string
#  type              :string           default("Bot"), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_bots_on_name  (name)
#  index_bots_on_type  (type)
#
class Bot < ApplicationRecord
  attribute :name, :string, default: Faker::Name.name
  attribute :role, :string, default: Faker::Job.title

  list_to_text :goals

  has_many :chats, dependent: :nullify

  before_create :set_intro

  def image_url
    super || generated_image_url
  end

  def generated_image_url
    @generated_image_url ||= "https://robohash.org/#{name}.png?size=640x640&set=set1"
  end

  def self.default
    where(name: "Gerald", role: "GPT Assistant").first_or_create do |bot|
      bot.directive = "You are a smart and friendly general purpose chatbot."
      bot.intro = "I'm a friendly bot that helps you get things done."
      bot.auto_archive_mins = 0
    end
  end

  def self.others
    where.not(id: default.id).order(:name)
  end

  private

  def set_intro
    self.intro = Gpt.chat(prompt: Prompts.get("bots.intro", {name: name, role: role}), max_tokens: 120, temperature: 0.8)
  end
end
