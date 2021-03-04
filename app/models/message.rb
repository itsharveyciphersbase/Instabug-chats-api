class Message < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
  belongs_to :chat, counter_cache: true

  before_validation :set_number
  validates_presence_of :message_body
  validates_uniqueness_of :number, scope: :chat_id

  settings do
    mappings dynamic: false do
      indexes :message_body, type: :text
      indexes :chat_id, type: :integer
    end
  end

  def redis_key
    "message_#{chat_id}_#{number}"
  end

  def write_to_redis!(message_params = {})
    self.number = chat.next_message_number
    message_params.merge!(number: number)
    message_params.merge!(message_body: message_body)

    RedisCache.set(
      redis_key,
      {
        chat_id: chat_id,
        message_params: message_params
      }.to_json
    )

    chat.increment_pending_messages_count
  end

  def self.search_chat(query, id)
      self.search({
        query: {
          bool: {
            must: [
            {
              multi_match: {
                query: query,
                fields: [:message_body],
                fuzziness: "AUTO"
              }
            },
            {
              match: {
                chat_id: id
              }
            }]
          }
        }
      })
  end

  private
  def set_number
    self.number = chat.messages_count + 1
  end

end
