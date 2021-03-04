class ChatsController < ApplicationController
  before_action :set_application, only: [:create, :index, :show, :update]

  def index
    render json: { chats: @application.chats }, status: :ok
  end

  def create
    chat = @application.chats.new

    if chat.valid?
      chat.write_to_redis!

      ChatCreator.perform_async(chat.redis_key)
      
      render json: { chat_number: chat.number }, staus: :created
    else
      render json: { errors: chat.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  def show
    chat = @application.chats.find_by(number: params[:number])
    render json: {chat: chat}, status: :ok
  end

  private
  
  def set_application
    @application = Application.find_by(token: params[:application_token])

    render json: { error: 'can not find application w/ this token' }, status: :not_found unless @application
  end
end
