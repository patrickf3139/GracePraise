class PraiseSetsController < ApplicationController

  before_action :require_edit_privileges, only: [:new, :create, :edit, :update]
  before_action :require_delete_privileges, only: [:destroy] # implement destroy later

  def index
    respond_to do |format|
      @praise_sets = PraiseSet.order(date: :desc)
      format.json do
        render json: @praise_sets and return
      end
      format.html do
      end
    end
  end

  def new
    @praise_set = PraiseSet.new
  end

  def create
    @praise_set = PraiseSet.new(praise_set_params)
    if @praise_set.save
      flash[:success] = "#{@praise_set} successfully created!"
      logger.info "New praise set created: #{current_user} created #{@praise_set}"
      redirect_to root
    else
      render :index
    end
  end

  private

  def praise_set_params
    params.require(:praise_set).permit(:name, :owner)
  end
end