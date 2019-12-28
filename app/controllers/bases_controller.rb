class BasesController < ApplicationController

  def index
    @bases = Base.all
  end

  def create
    @base = Base.new(base_params)
    if @base.save
      flash[:success] = '拠点情報を追加しました。'
      redirect_to bases_url
    else
      flash[:danger] = "無効な入力データがあった為、拠点情報追加をキャンセルしました。"
      redirect_to bases_url
    end
  end

  def update
    @base = Base.find(params[:basis_id])
    if @base.update_attributes(base_params)
      flash[:success] = "拠点情報を修正しました。"
      redirect_to bases_url
    else
      flash[:danger] = "無効な入力データがあった為、拠点情報編集をキャンセルしました。"
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