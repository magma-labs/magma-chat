# == Schema Information
#
# Table name: thoughts
#
#  id           :uuid             not null, primary key
#  brief        :string           not null
#  content      :jsonb            not null
#  importance   :integer          default(50), not null
#  subject_type :string
#  type         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  bot_id       :uuid             not null
#  subject_id   :uuid
#
# Indexes
#
#  index_thoughts_on_bot_id   (bot_id)
#  index_thoughts_on_brief    (brief)
#  index_thoughts_on_subject  (subject_type,subject_id)
#
class Observation < Thought
  JSON_SCHEMA = {
    "$schema" => "http://json-schema.org/draft-07/schema#",
    title: "ObservationList",
    description: "A structured list of observations made by a Bot during conversations with MagmaChat users.",
    type: "array",
    items: {
      type: "object",
      properties: {
        brief: {
          type: "string",
          maxLength: 280,
          description: "The text observation rewritten in the voice of the Bot involved and summarized if necessary to meet the maxLength constraint."
        },
        importance: {
          type: "integer",
          minimum: 1,
          maximum: 100,
          description: "On the scale of 1 to 100, where 1 is insignificant and 100 is extremely important, rate how likely it is that this observation will be useful information for the Bot in the future."
        },
        subject_type: {
          type: "string",
          enum: ["World", "Project", "Company", "Bot", "Human", "Task"],
          description: "A string indicating the type of the subject of the observation."
        },
        subject_id: {
          type: "string",
          format: "uuid",
          description: "A UUID string corresponding to the known subject identified as the subject_type of this observation."
        },
        subject_name: {
          type: "string",
          description: "The name of the subject, only if it is not a known subject."
        }
      },
      required: ["brief", "importance", "subject_type"],
      additionalProperties: false
    }
  }
end
