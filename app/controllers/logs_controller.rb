class LogsController < ApplicationController
  
  before_action :set_user, only: :index
  before_action :set_one_month, only: :index
  
  def index
    @one_month_logs = Log.where.not(syouninbi: nil)

  end
  
  private
  
  
  
end
