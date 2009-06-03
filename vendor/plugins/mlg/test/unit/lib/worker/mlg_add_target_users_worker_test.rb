require File.dirname(__FILE__) + '/../../../test_helper'
require "#{RAILS_ROOT}/lib/workers/mlg_add_target_users_worker"

module MlgAddTargetUsersWorkerTestModule
  
  class << self
    def included(base)
      base.class_eval do
        fixtures :base_users
        fixtures :prf_profiles
        fixtures :prf_answers
        fixtures :pnt_masters
        fixtures :pnt_points
        fixtures :mlg_magazines
        fixtures :mlg_deliveries
      end
    end
  end
  
  # 送信対象となるユーザを追加するテスト
  def test_add_target_users
    request_params = Hash.new
    # 対象ユーザ条件
    point_info = Hash.new
    point_info[:pnt_master_id] = 1
    point_info[:start_point] = 0
    point_info[:end_point] = 100
    
    request_params[:point_info] = point_info
    request_params[:user_info] = Hash.new
    request_params[:profile_info] = Hash.new
    request_params[:mlg_magazine_id] = 4
    
    # ポイントが100以下のユーザに対してメールマガジンID4を送信設定
    worker = MlgAddTargetUsersWorker.new
    worker.regist_delivery(request_params)
    #job_key = @middleman.new_worker(:class => :mlg_add_target_users_worker, :args => request_params)
    #sleep 0.2 while @middleman.get_worker(job_key)
    
    derivery = MlgDelivery.find(:all, :conditions => [' mlg_magazine_id = 4 '])
    
    assert_equal(derivery.size, 4)  # 対象ユーザ4名
    assert_equal(derivery[0].base_user_id, 1)
    assert_equal(derivery[1].base_user_id, 4)
  end
  
end
