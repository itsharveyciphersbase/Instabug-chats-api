class MessagesController < ApplicationController
  before_action :set_application, only: [:create, :index, :show, :update, :search]
  before_action :set_chat, only: [:create, :index, :show, :update, :search]

  def index
    render json: { chats: @chat.messages }, status: :ok
  end

  def create
    message = @chat.messages.new(message_params)

    if message.valid?
      message.write_to_redis!

      MessageCreator.perform_async(message.redis_key)
      
      render json: { message_number: message.number}, status: :created
    else
      render json: { errors: message.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def show
    message = @chat.messages.find_by(number: params[:number])
    render json: {message: message}, status: :ok
  end

  def update
    message = @chat.messages.find_by(number: params[:number])
    if message.update(message_params)
      render json: {message: message}, status: :ok
    else
      render json: {errors: message}, status: :bad_request
    end
  end


  def search
    render json: { Messages: Message.search_chat(params['message_body'], @chat.id) }, status: :ok
  end

  private
  def set_application
    @application = Application.find_by(token: params[:application_token])

    render json: { error: 'can not find application w/ this token' }, status: :not_found unless @application
  end

  def set_chat
    @chat = @application.chats.find_by(number: params[:chat_number])
  end

  def message_params
    params.require(:message).permit(:message_body)
  end
end
