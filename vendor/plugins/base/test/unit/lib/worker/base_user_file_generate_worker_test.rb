require File.dirname(__FILE__) + '/../../../test_helper'
require "#{RAILS_ROOT}/lib/workers/base_user_file_generate_worker"

module BaseUserFileGenerateWorkerTestModule
  
  class << self
    def included(base)
      base.class_eval do
        fixtures :base_users
        fixtures :base_profiles
        fixtures :base_user_roles
        fixtures :base_user_file_histories
        fixtures :pnt_points
        fixtures :pnt_masters
      end
    end
  end
  
  define_method('test: 削除されていない全ユーザを取得する') do 
    request_params = request_params_init
    
    worker = BaseUserFileGenerateWorker.new
    worker.generate(request_params)
    
    base_user_file_history = BaseUserFileHistory.find(1)
    assert_not_nil(base_user_file_history)
    assert_not_nil(base_user_file_history.complated_at) # 完了日付が入っている
    
    assert_equal(line_count(base_user_file_history), BaseUser.count(:conditions => ['status = 2']) + 1) # 有効な全ユーザ＋ヘッダレコード分出力されている
  end
  
  define_method('test: 会員IDがthreeのユーザを取得する') do 
    request_params = request_params_init
    
    request_params[:user_info] = {:login => ['three']}
    
    worker = BaseUserFileGenerateWorker.new
    worker.generate(request_params)
    
    base_user_file_history = BaseUserFileHistory.find(1)
    assert_not_nil(base_user_file_history)
    assert_not_nil(base_user_file_history.complated_at) # 完了日付が入っている
    
    assert_equal(line_count(base_user_file_history), 2) # ユーザ＋ヘッダレコード分出力されている
  end
  
  define_method('test: 500ポイント以上保持しているユーザ一覧を取得する') do 
    request_params = request_params_init
    
    request_params[:point_info] = {:pnt_master_id => 1, :start_point => 500}
    
    worker = BaseUserFileGenerateWorker.new
    worker.generate(request_params)
    
    base_user_file_history = BaseUserFileHistory.find(1)
    assert_not_nil(base_user_file_history)
    assert_not_nil(base_user_file_history.complated_at) # 完了日付が入っている
    
    result_count = PntPoint.count(:base_user_id, :conditions => [ "point > 500 and pnt_master_id = 1"])
    assert_equal(line_count(base_user_file_history), result_count+1) # ＋ヘッダレコード分出力されている
  end
  
  define_method('test: 10ポイント以上所有しており、かつdocomoユーザ一覧を取得する') do 
    request_params = request_params_init
    
    request_params[:user_info] = {:base_carrier_id => [1]}
    request_params[:point_info] = {:pnt_master_id => 1, :start_point => 10}
    
    worker = BaseUserFileGenerateWorker.new
    worker.generate(request_params)
    
    base_user_file_history = BaseUserFileHistory.find(1)
    assert_not_nil(base_user_file_history)
    assert_not_nil(base_user_file_history.complated_at) # 完了日付が入っている
    
    target_pnt_points = PntPoint.find(:all, :conditions => [ "point > 10 and pnt_master_id = 1"])
    base_users = BaseUser.find(:all, :conditions => ['base_carrier_id = 1'])
    result_count = 0
    target_pnt_points.each do |target|
      base_users.each do |base_user|
        result_count += 1 if target.base_user_id == base_user.id
      end
    end  
    assert_equal(line_count(base_user_file_history), result_count+1) # ＋ヘッダレコード分出力されている
  end
  
  define_method('test: 10ポイント以上所有しており、かつdocomoかauのユーザ一覧を取得する') do 
    request_params = request_params_init
    
    request_params[:user_info] = {:base_carrier_id => [1,2]}
    request_params[:point_info] = {:pnt_master_id => 1, :start_point => 10}
    
    worker = BaseUserFileGenerateWorker.new
    worker.generate(request_params)
    
    base_user_file_history = BaseUserFileHistory.find(1)
    assert_not_nil(base_user_file_history)
    assert_not_nil(base_user_file_history.complated_at) # 完了日付が入っている
    
    target_pnt_points = PntPoint.find(:all, :conditions => [ "point > 10 and pnt_master_id = 1"])
    base_users = BaseUser.find(:all, :conditions => ['base_carrier_id in ( 1, 2 )'])
    result_count = 0
    target_pnt_points.each do |target|
      base_users.each do |base_user|
        result_count += 1 if target.base_user_id == base_user.id
      end
    end  
    assert_equal(line_count(base_user_file_history), result_count+1) # ＋ヘッダレコード分出力されている
  end
  
  define_method('test: 5000 ポイント以下を所有しており、かつauユーザ一覧を取得する') do 
    request_params = request_params_init
    
    request_params[:user_info] = {:base_carrier_id => [2]}
    request_params[:point_info] = {:pnt_master_id => 1, :end_point => 5000}
    
    worker = BaseUserFileGenerateWorker.new
    worker.generate(request_params)
    
    base_user_file_history = BaseUserFileHistory.find(1)
    assert_not_nil(base_user_file_history)
    assert_not_nil(base_user_file_history.complated_at) # 完了日付が入っている
    
    target_pnt_points = PntPoint.find(:all, :conditions => [ "point < 5000 and pnt_master_id = 1"])
    base_users = BaseUser.find(:all, :conditions => ['base_carrier_id = 2 '])
    result_count = 0
    target_pnt_points.each do |target|
      base_users.each do |base_user|
        result_count += 1 if target.base_user_id == base_user.id
      end
    end  
    assert_equal(line_count(base_user_file_history), result_count+1) # ＋ヘッダレコード分出力されている
  end
  
  define_method('test: 男性ユーザ一覧を取得する') do 
    request_params = request_params_init
    
    request_params[:profile_info] = {:sex => [0]}
    
    worker = BaseUserFileGenerateWorker.new
    worker.generate(request_params)
    
    base_user_file_history = BaseUserFileHistory.find(1)
    assert_not_nil(base_user_file_history)
    assert_not_nil(base_user_file_history.complated_at) # 完了日付が入っている
    
    result_count = BaseProfile.count(:all, :conditions => [ " sex = 0 "])
    assert_equal(line_count(base_user_file_history), result_count+1) # ＋ヘッダレコード分出力されている
  end
  
  define_method('test: ニックネームに[てすと]を含むユーザー一覧を取得一覧を取得する') do 
    request_params = request_params_init
    
    request_params[:profile_info] = {:name => 'てすと'}
    
    worker = BaseUserFileGenerateWorker.new
    worker.generate(request_params)
    
    base_user_file_history = BaseUserFileHistory.find(1)
    assert_not_nil(base_user_file_history)
    assert_not_nil(base_user_file_history.complated_at) # 完了日付が入っている
    
    result_count = BaseProfile.count(:all, :conditions => [ " name like ? ", "%テスト%"])
    assert_equal(line_count(base_user_file_history), result_count+1) # ＋ヘッダレコード分出力されている
  end
  
  define_method('test: auの男性ユーザ一覧を取得する') do 
    request_params = request_params_init
    
    request_params[:user_info] = {:base_carrier_id => [2]}
    request_params[:profile_info] = {:sex => [0]}
    
    worker = BaseUserFileGenerateWorker.new
    worker.generate(request_params)
    
    base_user_file_history = BaseUserFileHistory.find(1)
    assert_not_nil(base_user_file_history)
    assert_not_nil(base_user_file_history.complated_at) # 完了日付が入っている
    
    target_users = BaseProfile.find(:all, :conditions => [ " sex = 0 "])
    base_users = BaseUser.find(:all, :conditions => ['base_carrier_id = 2 '])
    result_count = 0
    target_users.each do |target|
      base_users.each do |base_user|
        result_count += 1 if target.base_user_id == base_user.id
      end
    end
    
    assert_equal(line_count(base_user_file_history), result_count+1) # ＋ヘッダレコード分出力されている
  end
  
  define_method('test: 10 ポイント以上所有しており、かつdocomoかauの女性ユーザ一覧を取得する') do 
    request_params = request_params_init
    
    request_params[:user_info] =  {:base_carrier_id => [1,2]}
    request_params[:profile_info] = {:sex => [1]}
    request_params[:point_info] = {:pnt_master_id => 1, :start_point => 10}
    
    worker = BaseUserFileGenerateWorker.new
    worker.generate(request_params)
    
    base_user_file_history = BaseUserFileHistory.find(1)
    assert_not_nil(base_user_file_history)
    assert_not_nil(base_user_file_history.complated_at) # 完了日付が入っている
    
    target_users = BaseProfile.find(:all, :conditions => [ " sex = 1 "])
    target_pnt_points = PntPoint.find(:all, :conditions => [ "point > 10 and pnt_master_id = 1"])
    base_users = BaseUser.find(:all, :conditions => ['base_carrier_id in (1,2) '])
    result_count = 0
    target_users.each do |target|
      target_pnt_points.each do |target_point|
        base_users.each do |base_user|
          result_count += 1 if target.base_user_id == base_user.id && target_point.base_user_id == base_user.id
        end
      end
    end
    
    assert_equal(line_count(base_user_file_history), result_count+1) # ＋ヘッダレコード分出力されている
  end
  
  define_method('test: 20才から26才のユーザ一覧を取得する') do 
    request_params = request_params_init
    
    request_params[:profile_info] = {:age_start => 20, :age_end => 26 }
    
    worker = BaseUserFileGenerateWorker.new
    worker.generate(request_params)
    
    base_user_file_history = BaseUserFileHistory.find(1)
    assert_not_nil(base_user_file_history)
    assert_not_nil(base_user_file_history.complated_at) # 完了日付が入っている
    
    birthday_start = Date.today << (20 * 12)
    birthday_start = birthday_start.strftime('%Y-%m-%d')
    
    birthday_end = (Date.today + 1) << ((26 + 1) * 12) # 20歳以下の人は、21年前(20 + 1 年前)の明日以降生まれた人
    birthday_end = birthday_end.strftime('%Y-%m-%d')
    
    result_count = BaseProfile.count(:base_user_id, :conditions => [ " birthday <= ? and birthday >= ? ", birthday_start, birthday_end])
    assert_equal(line_count(base_user_file_history), result_count+1) # ＋ヘッダレコード分出力されている
  end
  
  define_method('test: 10日前から3日前に参加したユーザ一覧を取得する') do 
    request_params = request_params_init
    
    joined_at_start = 10.days.ago.strftime('%Y-%m-%d')
    joined_at_end = 3.days.ago.strftime('%Y-%m-%d')
    request_params[:user_info] = {:joined_at_start => joined_at_start, :joined_at_end => joined_at_end}
    
    worker = BaseUserFileGenerateWorker.new
    worker.generate(request_params)
    
    base_user_file_history = BaseUserFileHistory.find(1)
    assert_not_nil(base_user_file_history)
    assert_not_nil(base_user_file_history.complated_at) # 完了日付が入っている
    
    result_count = BaseUser.count(:all, :conditions => [ " joined_at between ? and ? and status = 2", joined_at_start, joined_at_end])
    assert_equal(line_count(base_user_file_history), result_count+1) # ＋ヘッダレコード分出力されている
  end
  
  define_method('test: 3日前から参加してかつ女性ユーザ一覧を取得する') do 
    request_params = request_params_init
    
    request_params[:user_info] = {:joined_at_start => 3.days.ago.strftime('%Y-%m-%d')}
    request_params[:profile_info] = {:sex =>[1]}
    
    worker = BaseUserFileGenerateWorker.new
    worker.generate(request_params)
    
    base_user_file_history = BaseUserFileHistory.find(1)
    assert_not_nil(base_user_file_history)
    assert_not_nil(base_user_file_history.complated_at) # 完了日付が入っている
    
    result_count = 0
    tareget_users = BaseProfile.find(:all, :conditions => [ " sex = 1 "])
    base_users = BaseUser.find(:all, :conditions => [ " joined_at >= ? and status = 2", 3.days.ago.strftime('%Y-%m-%d')])
    tareget_users.each do |target|
      base_users.each do |base_user|
        result_count += 1 if target.base_user_id == base_user.id
      end
    end
    assert_equal(line_count(base_user_file_history), result_count+1) # ＋ヘッダレコード分出力されている
  end
  
  def line_count(base_user_file_history)
    result_file_name = AppResources[:base][:user_csv_file_path] + "/" + base_user_file_history.file_name
    
    line_count = 0
    open(result_file_name) do |file|
      while l = file.gets do
        line_count += 1
      end
    end
    return line_count
  end
  
  def request_params_init
    request_params = {:user_info => {}, :point_info => {}, :profile_info => {}}
    request_params[:base_user_file_history_id] = 1
    return request_params
  end
end