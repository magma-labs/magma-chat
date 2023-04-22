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
#  published_at      :datetime
#  role              :string
#  settings          :jsonb            not null
#  type              :string           default("Bot"), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_bots_on_name          (name)
#  index_bots_on_published_at  (published_at)
#  index_bots_on_type          (type)
#
class Bot < ApplicationRecord
  attribute :name, :string, default: Faker::Name.name
  attribute :role, :string, default: Faker::Job.title

  # todo: need an attribute for desired response size in tokens

  has_many :chats, dependent: :nullify
  has_many :thoughts, dependent: :destroy
  has_many :observations, dependent: :destroy

  before_create :set_intro

  scope :published, -> { where.not(published_at: nil) }
  scope :unpublished, -> { where(published_at: nil) }

  def image_url
    super || generated_image_url
  end

  def generated_image_url
    @generated_image_url ||= "https://robohash.org/#{name}.png?size=640x640&set=set1"
  end

  def observed!(chat, list_of_observations)
    list_of_observations.each do |params|
      subject_name = params.delete(:about)
      observations.build(params).then do |observation|
        observation.subject = subject_name["conversation"] ? chat : chat.user
        if observation.save
          # no problem
        else
          # todo: is there a less clumsy more expressive way of doing this?
          observations.find_by(subject: observation.subject, brief: params[:brief]).then do |eo|
            eo.increment!(:importance, params[:importance].to_i)
          end
        end

      end
    end
  end

  def top_memories_of(user)
    observations.by_user(user).by_decayed_score.limit(20).map(&:brief_with_timestamp)
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

  def to_partial_path
    "bots/bot"
  end

  private

  def set_intro
    self.intro = Gpt.chat(
      prompt: Prompts.get("bots.intro", {name: name, role: role}),
      max_tokens: 120,
      temperature: 0.8
    )
  end
end
