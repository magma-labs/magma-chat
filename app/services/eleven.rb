require 'httparty'

module Eleven
  extend self

  def api_key
    @api_key ||= ENV['XI_API_KEY']
  end

  def tts(voice_id: "21m00Tcm4TlvDq8ikWAM", text:, stability: 0.5, similarity_boost: 0.5)
    return if api_key.blank?
    data = {
      "text": text,
      "voice_settings": {
        "stability": stability,
        "similarity_boost": similarity_boost
      }
    }
    options = {
      headers: { 'Content-Type' => 'application/json',  "xi-api-key": api_key },
      body: data.to_json
    }

    HTTParty.post(tts_url(voice_id), options)
  end

  private

  def file_name
    "#{SecureRandom.uuid}.mp3"
  end

  def tts_url(voice_id)
    "https://api.elevenlabs.io/v1/text-to-speech/#{voice_id}/stream?optimize_streaming_latency=1"
  end
end
