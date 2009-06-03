require File.dirname(__FILE__) + '/../test_helper'

# lib/pnt_point_systemのテストなので本来 unit/lib いかにおくべきだたテスト自体は　controllerを使ったテストのため
# functional以下に格納する。 unit/lib以下に格納すると　いくつかのテストが正常に動かないので要注意
class PointSystemTestController < ActionController::Base
  include PntPointSystem
  around_filter :pnt_target_filter
  
  # 通常のポイント換算処理
  def target
    render :nothing => true
  end
  
  def rule_count_target
    render :nothing => true
  end
  
  def rule_day_target
    render :nothing => true
  end
  
  def stock_target
    render :nothing => true
  end
  
  def term_target
    render :nothing => true
  end
  
  # ポイント換算がされない処理
  def exception_target
    params[:pnt_request_cancel] = true
    render :nothing => true
  end
  
  # 履歴情報更新時に問題が発生するデータのため、処理途中で例外が発生する処理
  def roleback_target
    render :nothing => true
  end
  
  def rescue_action(e) 
    raise e
  end
    
end

# テスト時に任意の場所で例外を起こすためのMockクラス
#
# example)
#  
#  def test_hoge
#    PntHistory.set_save_error # 保存時にエラーを起こす
#    ## テスト実行
#　　  PntHistory.unset_save_error # ほかのテストに影響を与えるのでもとに戻す
#  end
#
class PntHistory < ActiveRecord::Base
  include PntHistoryModule
  @@save_error = false
  
  def self.set_save_error
    @@save_error = true
  end
  
  def self.unset_save_error
    @@save_error = false
  end
  
  def save!
    if @@save_error # 明示的にエラーを起こす
      raise ActiveRecord::RecordNotFound
      return
    else
      super
    end
  end
  
end

module PntPointSystemTestModule 
  class << self
    def included(base)
      base.class_eval do
        include PntPointSystem
        include TestUtil::Base::MobileControllerTest
        fixtures :base_users
        fixtures :pnt_filters
        fixtures :pnt_filter_masters
        fixtures :pnt_masters
        fixtures :pnt_points
        fixtures :pnt_histories
        
        self.use_transactional_fixtures = false
      end
    end
  end

  # 通常の加算処理のテスト
  def test_normal_add
    test_user = BaseUser.authenticate('quentin', 'test')
    @request.session[:base_user] = test_user
    
    get :target
    
    # pnt_filter assert
    pnt_filter = PntFilter.find(1)
    assert_equal(pnt_filter.stock,-1) # リミットなしなので減らない
    
    # pnt_points assert 
    point = PntPoint.find_by_base_user_id(test_user.id)
    assert_equal(point.point,110) # ポイント増加
    
    # pnt_hisotries assert 
    history = PntHistory.find(:first, :conditions => ['message = ? ', 'test追加'])
    assert_not_nil history
    assert_equal(history.difference, 10)
    assert_equal(history.amount, 110) 
  end
  
  # rule_count が指定されている場合の加算テスト
  # rule_count = 3, テストユーザーの pnt_histories.count = 2
  def test_add_with_rule
    test_user = BaseUser.authenticate('test3@test', 'test')
    @request.session[:base_user] = test_user
    
    # 1回め
    get :rule_count_target
    
    # pnt_points assert 
    point = PntPoint.find_by_base_user_id(test_user.id)
    assert_equal(point.point, 150) # ポイント増加

    
    # 2回め
    get :rule_count_target
    
    # pnt_points assert 
    point = PntPoint.find_by_base_user_id(test_user.id)
    assert_equal(point.point, 150) # ポイント増加なし
  end
  
  # rule_count, rule_day が指定されている場合の加算テスト
  # rule_count = 3, rule_day = 2, histories.count = 2
  # テストユーザーの2日以内の pnt_histories.count = 2
  # テストユーザーのそれ以前の pnt_histories.count = 1
  def test_add_with_rule
    test_user = BaseUser.authenticate('four', 'test')
    @request.session[:base_user] = test_user
    
    # 1回め
    get :rule_day_target
    
    # pnt_points assert 
    point = PntPoint.find_by_base_user_id(test_user.id)
    assert_equal(point.point, 160) # ポイント増加

    
    # 2回め
    get :rule_day_target
    
    # pnt_points assert 
    point = PntPoint.find_by_base_user_id(test_user.id)
    assert_equal(point.point, 160) # ポイント増加なし
  end
  
  # 配布制限テスト
  # stock = 1回分
  def test_add_with_stock
    test_user = BaseUser.authenticate('four', 'test')
    @request.session[:base_user] = test_user
    
    # 1回め
    get :stock_target
    
    # pnt_points assert 
    point = PntPoint.find_by_base_user_id(test_user.id)
    assert_equal(point.point, 170) # ポイント増加

    
    # 2回め
    get :stock_target
    
    # pnt_points assert 
    point = PntPoint.find_by_base_user_id(test_user.id)
    assert_equal(point.point, 170) # ポイント増加なし
  end
  
  # 配布期間テスト
  # pnt_filter 2種類あるけど、片方は期間外
  def test_add_with_stock
    test_user = BaseUser.authenticate('four', 'test')
    @request.session[:base_user] = test_user
    
    get :term_target
    
    # pnt_points assert 
    point = PntPoint.find_by_base_user_id(test_user.id)
    assert_equal(point.point, 180) # ポイント増加
  end
  
  # 処理に問題があったのでポイント加算はしないでほしいときのテスト
  def test_exception
    test_user = BaseUser.authenticate('aaron', 'test')
    @request.session[:base_user] = test_user
    
    begin
      get :exception_target # 例外が発生するのでポイント増加をしない
    rescue PntPointSystem::PntExerciseException
    end
    
    # pnt_filter assert
    pnt_filter = PntFilter.find(1)
    assert_equal(pnt_filter.stock,-1) # 減らない
      
    # assert 
    point = PntPoint.find_by_base_user_id(test_user.id)
    assert_equal(point.point, 200) # 例外が発生するのでポイント増加をしない
    
    # pnt_hisotries assert 
    history = PntHistory.find(:first, :conditions => ['pnt_point_id = ? and message = ? ', point.id, "test追加"], :order => 'created_at desc')
    assert_nil history # 記録も残らない
  end
  
  # ログインしてないユーザがfiterを通ってもエラーにならなかテスト
  def test_not_user
    # セッション情報なし
    #test_user = BaseUser.authenticate('quentin', 'test')
    #@request.session[:base_user] = test_user
    
    get :target
  end
  
  define_method('test: ポイントを配布する途中で問題がおこったら配布処理はされない') do
    login_as :quentin
    PntHistory.set_save_error # 保存時にエラーを起こす
    
    post :target
    
    point = PntPoint.find_by_base_user_id(1)
    assert_equal(point.point, 100) # ポイント増加しない
    
    PntHistory.unset_save_error
  end
  
end