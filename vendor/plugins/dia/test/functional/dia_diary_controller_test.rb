require File.dirname(__FILE__) + '/../test_helper'

module DiaDiaryControllerTestModule
  
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::MobileControllerTest
        
        fixtures :base_users
        fixtures :base_friends
        fixtures :dia_diaries
        fixtures :dia_entries
        fixtures :dia_entry_comments
      end
    end
  end
  
  define_method('test: 日記設定画面を表示する') do 
    login_as :quentin
    
    post :edit
    assert_response :success
    assert_template 'edit_mobile'
  end
  
  define_method('test: 日記設定編集画面を表示する') do 
    login_as :quentin
    
    post :update_confirm, :diary => { :default_public_level => 1}
    assert_response :success
    assert_template 'update_confirm_mobile'
  end
  
  define_method('test: 日記設定の編集を実行する') do 
    login_as :quentin
    
    # 事前チェック：公開設定は1
    dia_diary = DiaDiary.find(:first, :conditions => ' base_user_id = 1 ')
    assert_equal dia_diary.default_public_level, 1
    
    post :update, :diary => { :default_public_level => 3}
    assert_response :redirect 
    assert_redirected_to :action => 'update_done'
    
    after_dia_diary = DiaDiary.find(:first, :conditions => ' base_user_id = 1 ')
    assert_equal after_dia_diary.default_public_level, 3 # 3に更新されている
  end
  
  define_method('test: 日記設定の編集をキャンセルする') do 
    login_as :quentin
    
    post :update, :diary => { :default_public_level => 2}, :cancel => 'true'
    assert_response :success
    assert_template 'edit_mobile'
    
    after_dia_diary = DiaDiary.find(:first, :conditions => ' base_user_id = 1 ')
    assert_not_equal after_dia_diary.default_public_level, 2 # 更新はされてない
  end
end
