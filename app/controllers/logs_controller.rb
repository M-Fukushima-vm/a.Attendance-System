class LogsController < ApplicationController
  
  before_action :set_user, only: :index
  # before_action :set_one_month, only: :index
  
  
  def index
    # debugger
      @first_day = params[:date].nil? ?
      Date.current.beginning_of_month : params[:date].to_date
      @last_day = @first_day.end_of_month
    @one_month_logs = Log.where(user_id: params[:id], hiduke: @first_day..@last_day).order(syouninbi: "DESC")

  end
  
  private
  
  
  
end
