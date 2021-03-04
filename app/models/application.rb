class Application < ApplicationRecord
  has_secure_token

  has_many :chats

  validates_presence_of :name
  validates_uniqueness_of :token

  def redis_key
    "application_#{id}"
  end
  
  def pending_chats_count 
    RedisCache.get(redis_key).to_i
  end
  
  def next_chat_number
    chats_count + pending_chats_count + 1
  end

  def increment_pending_chats_count
    RedisCache.set(redis_key, pending_chats_count + 1)
  end

  def decrement_pending_chats_count
    RedisCache.set(redis_key, pending_chats_count - 1)
  end

  def reset_pending_chats_count
    RedisCache.set(redis_key, 0)
  end
  
end