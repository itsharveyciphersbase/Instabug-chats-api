class ApplicationsController < ApplicationController

  def index
    applications = Application.all
    render json: { applications: applications}, status: :ok
  end

  def create
    application = Application.new(application_params)

    if application.save
      render json: { token: application.token }, status: :created
    else
      render json: { errors: application.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def show
    application = Application.find_by(token: params[:token])
    render json: {application: application}, status: :ok
  end

  private

  def application_params
    params.require(:application).permit(:name)
  end
end
