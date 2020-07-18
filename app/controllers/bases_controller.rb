class BasesController < ApplicationController

  def index
    if current_user.admin?
      @bases = Base.all.order(:number)
    else
      flash[:danger] = '権限がありません。'
      redirect_to user_url(current_user.id)
    end
  end

  def create
    @base = Base.new(base_params)
    if @base.save
      flash[:success] = '拠点情報を追加しました。'
      redirect_to bases_url
    else
      # flash[:danger] = "無効な入力データがあった為、拠点情報追加をキャンセルしました。"
      flash[:danger] = "#{@base.name}の追加は失敗しました。<br>" + @base.errors.full_messages.join("<br>")
      redirect_to bases_url
      
    end
  end

  def update
    @base = Base.find(params[:basis_id])
    if @base.update_attributes(base_params)
      flash[:success] = "拠点情報を修正しました。"
      redirect_to bases_url
    else
      # flash[:danger] = "無効な入力データがあった為、拠点情報編集をキャンセルしました。"
      flash[:danger] = "#{@base.name}の更新は失敗しました。<br>" + @base.errors.full_messages.join("<br>")
      redirect_to bases_url  
    end
  end

  def destroy
    @base = Base.find(params[:id])
    @base.destroy
    flash[:success] = "#{@base.name}のデータを削除しました。"
    redirect_to bases_url
  end


  private

    def base_params
      params.require(:base).permit(:number, :name, :assortment)
    end


end