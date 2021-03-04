class ChatCreator
  include Sidekiq::Worker

  def perform(redis_key)
    params = JSON.parse(RedisCache.get(redis_key), symbolize_keys: true)
    application_id = params['application_id']

    application = Application.lock.find_by(id: application_id)

    if application
      application.chats.create(number: params['chat_params']['number'])

      application.decrement_pending_chats_count
    end
  end
end