class Chat < ApplicationRecord
  belongs_to :application, counter_cache: true
  has_many :messages

  before_validation :set_number
  validates_uniqueness_of :number, scope: :application_id

  def redis_key
    "#{application_id}_#{number}"
  end
  
  def write_to_redis!(chat_params = {})
    self.number = application.next_chat_number
    chat_params.merge!(number: number)

    RedisCache.set(
      redis_key,
      {
        application_id: application_id,
        chat_params: chat_params
      }.to_json
    )

    application.increment_pending_chats_count
  end

  def pending_messages_count 
    RedisCache.get(redis_key).to_i
  end
  
  def next_message_number
    messages_count + pending_messages_count + 1
  end

  def increment_pending_messages_count
    RedisCache.set(redis_key, pending_messages_count + 1)
  end

  def decrement_pending_messages_count
    RedisCache.set(redis_key, pending_messages_count - 1)
  end

  def reset_pending_messages_count
    RedisCache.set(redis_key, 0)
  end

  private

  def set_number
    # TODO: handle race condition
    self.number = application.chats_count + 1
  end
end
