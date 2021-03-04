class MessageCreator
  include Sidekiq::Worker

  def perform(redis_key)
    params = JSON.parse(RedisCache.get(redis_key), symbolize_keys: true)
    chat_id = params['chat_id']
    print params
    chat = Chat.lock.find_by(id: chat_id)

    if chat
      chat.messages.create(message_body: params['message_params']['message_body'],
      number: params['message_params']['number'])

      chat.decrement_pending_messages_count
    end
  end
end