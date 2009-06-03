require File.dirname(__FILE__) + '/../../test_helper'

module Manage::MlgDeliveryControllerTestModule
    
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::PcControllerTest
        fixtures :base_users
        fixtures :base_user_roles
        fixtures :mlg_magazines
        fixtures :mlg_deliveries
        fixtures :pnt_masters
        fixtures :prf_question_sets
      end
    end
  end

  define_method('test: メールマガジン配信設定画面を表示する') do 
    login_as :quentin
  
    post :setup, :id => 1
    assert_response :success
    assert_template 'setup'
  end

  define_method('test: メールマガジン配信設定確認画面を表示する') do 
    login_as :quentin
  
    post :confirm, :mlg_magazine => {:id => 5, "send_at(1i)"=>"2008", "send_at(2i)"=>"1", "send_at(3i)"=>"31", "send_at(4i)"=>"00", "send_at(5i)"=>"00"}, 
                   :pnt_master => {:id => 1}, :joined_at => {}, :age => {}, :point => {}
    assert_response :success
    assert_template 'confirm'
  
    assert_equal(assigns(:user_count), 6)
  end

  define_method('test: メールマガジン配信設定確認画面を表示しようとするが配信日が存在しない日付なので警告を表示する') do 
    login_as :quentin
  
    post :confirm, :mlg_magazine => {:id => 5, "send_at(1i)"=>"2008", "send_at(2i)"=>"2", "send_at(3i)"=>"31", "send_at(4i)"=>"00", "send_at(5i)"=>"00"}, 
                   :pnt_master => {:id => 1}, :joined_at => {}, :age => {}, :point => {}
    assert_response :success
    assert_template 'setup'
  end
  
  define_method('test: 参加開始日を条件に加えてメールマガジン配信設定確認画面を表示する') do 
    login_as :quentin
  
    post :confirm, :mlg_magazine => {:id => 5, "send_at(1i)"=>"2008", "send_at(2i)"=>"1", "send_at(3i)"=>"31", "send_at(4i)"=>"00", "send_at(5i)"=>"00"}, 
                   :pnt_master => {:id => 1}, 
                   :joined_at => { 'start(1i)' => '2000', 'start(2i)' => '01', 'start(3i)' => '01'}, 
                   :age => {}, :point => {}
    assert_response :success
    assert_template 'confirm'
  
    assert_equal(assigns(:user_count), 6)
  
    post :confirm, :mlg_magazine => {:id => 5, "send_at(1i)"=>"2008", "send_at(2i)"=>"1", "send_at(3i)"=>"31", "send_at(4i)"=>"00", "send_at(5i)"=>"00"}, 
                   :pnt_master => {:id => 1}, 
                   :joined_at => { 'start(1i)' => '2100', 'start(2i)' => '01', 'start(3i)' => '01'}, 
                   :age => {}, :point => {}
    assert_response :success
    assert_template 'confirm'
  
    assert_equal(assigns(:user_count), 0) # 参加日が遠い未来なので対象者は0
  end

  define_method('test: 年齢を条件に加えてメールマガジン配信設定確認画面を表示する') do 
    login_as :quentin
  
    post :confirm, :mlg_magazine => {:id => 5, "send_at(1i)"=>"2008", "send_at(2i)"=>"1", "send_at(3i)"=>"31", "send_at(4i)"=>"00", "send_at(5i)"=>"00"}, 
                   :pnt_master => {:id => 1}, 
                   :joined_at => {}, 
                   :age => {:start => 0, :end => 100}, 
                   :point => {}
    assert_response :success
    assert_template 'confirm'
  
    assert_equal(assigns(:user_count), 5)
  
    # 100歳以上はいないので0人
    post :confirm, :mlg_magazine => {:id => 5, "send_at(1i)"=>"2008", "send_at(2i)"=>"1", "send_at(3i)"=>"31", "send_at(4i)"=>"00", "send_at(5i)"=>"00"}, 
                   :pnt_master => {:id => 1}, 
                   :joined_at => {}, 
                   :age => {:start => 100}, 
                   :point => {}
    assert_response :success
    assert_template 'confirm'
  
    assert_equal(assigns(:user_count), 0)
  end

  define_method('test: ポイント数を条件に加えてメールマガジン配信設定確認画面を表示する') do 
    login_as :quentin
  
    post :confirm, :mlg_magazine => {:id => 5, "send_at(1i)"=>"2008", "send_at(2i)"=>"1", "send_at(3i)"=>"31", "send_at(4i)"=>"00", "send_at(5i)"=>"00"}, 
                   :pnt_master => {:id => 1}, :joined_at => {}, :age => {}, 
                   :point => { :pnt_master_id => 1, :start_point => 0, :end_point => 100}
    assert_response :success
    assert_template 'confirm'
  
    assert_equal(assigns(:user_count), 2)
  
    post :confirm, :mlg_magazine => {:id => 5, "send_at(1i)"=>"2008", "send_at(2i)"=>"1", "send_at(3i)"=>"31", "send_at(4i)"=>"00", "send_at(5i)"=>"00"}, 
                   :pnt_master => {:id => 1}, :joined_at => {}, :age => {}, 
                   :point => { :pnt_master_id => 1, :start_point => 0, :end_point => 1000}
    assert_response :success
    assert_template 'confirm'
  
    assert_equal(assigns(:user_count), 3)
  end

  define_method('test: メールマガジン配信設定実行処理をする') do 
    login_as :quentin
  
    post :update, :mlg_magazine => {:id => 5}, :pnt_master => {:id => 1}, :joined_at => {}, :age => {}, :point => {}
    assert_response :redirect
    assert_redirected_to :controller => 'mlg', :action => 'list'
  end


  define_method('test: 参加日を条件に加えてメールマガジン配信設定実行処理をする') do 
    login_as :quentin
  
    post :update, :mlg_magazine => {:id => 5}, 
                  :pnt_master => {:id => 1}, 
                  :joined_at => { 'start(1i)' => '2000', 'start(2i)' => '01', 'start(3i)' => '01',
                                  'end(1i)' => '2100', 'end(2i)' => '01', 'end(3i)' => '01'}, 
                  :age => {}, :point => {}
    assert_response :redirect
    assert_redirected_to :controller => 'mlg', :action => 'list'
  end
end
