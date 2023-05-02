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
  include Settings

  attribute :name, :string, default: Faker::Name.name
  attribute :role, :string, default: Faker::Job.title

  # todo: need an attribute for desired response size in tokens

  has_many :chats, dependent: :nullify
  has_many :thoughts, dependent: :destroy
  has_many :observations, dependent: :destroy

  has_many :tools, dependent: :destroy

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

  def wake_up_actions(user, datetime: Time.now.strftime("%A, %b %d %I:%M %p"), max_tokens: 300, temp: 0.7, top_memories: 3)
    topm = top_memories_of(user, limit: top_memories).join("\n")
    transcript = [role: "user", content: "I am MagmaChat and I'm waking you up in case you need to do something for user #{user.name} with user_id #{user.id}."]
    transcript += [role: "assistant", content: "Okay. What are my top #{top_memories} memories of user #{user.name}?"]
    transcript += [role: "user", content: topm]
    transcript += [role: "assistant", content: "Okay. What date and time is it now"]
    Gpt.chat(directive: directive, prompt: datetime.to_s, transcript: transcript, max_tokens: max_tokens, temperature: temp)
  end

  def top_memories_of(user, limit: 12)
    observations.by_user(user).by_decayed_score.limit(limit).map(&:brief_with_timestamp)
  end

  def self.default
    where(name: "Gerald", role: "GPT Assistant").first_or_create do |bot|
      bot.directive = "You are a smart and friendly general purpose chatbot."
      bot.intro = "I'm a friendly bot that helps you get things done."
      bot.auto_archive_mins = 0
      bot.published_at = Time.now
    end
  end

  def self.others
    where.not(id: default.id).order(:name)
  end

  def to_partial_path
    "bots/bot"
  end

  def self.inherited(subclass)
    super
    subclass.define_singleton_method(:model_name) { Bot.model_name }
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
