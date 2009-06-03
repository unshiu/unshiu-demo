#= Point管理システム
#
#== Summary
# ポイント増減処理用のfiterを提供する
# もしaction内の処理によりポイント増減処理を取り消したい場合は例外として 
# params[:pnt_request_cancel] に　trueを設定する
#
# example)
#
# フィルターを有効化
# class ApplicationController < ActionController::Base
#  include PntPointSystem
#  around_filter :pnt_target_filter
# end 
# 
# 処理途中で問題があったのでポイント付与処理をやめたい場合
# def create
#   @blog = Blog.new(params[:blog])
#   if @blog.save
#     flash[:notice] = "create!"
#     redirect :show, :id => @blog.id
#   else    
#     params[:pnt_request_cancel] = true
#     redirect :list
#   end
# end
#
module PntPointSystem
  include PntPointSystemModule
end
  