
require File.dirname(__FILE__) + '/../../../../../../lib/string_expanse.rb'

module Manage
  module BaseErrorControllerTestModule
  
    class << self
      def included(base)
        base.class_eval do
          include TestUtil::Base::PcControllerTest
          fixtures :base_users
          fixtures :base_ng_words
          fixtures :base_user_roles
          fixtures :base_errors
        end
      end
    end
   
    define_method('test: エラーコード管理画面トップページを表示する') do 
      login_as :quentin
      
      post :index
      assert_response :success
      assert_template 'list'
    end
  
    define_method('test: エラーコード一覧を表示する') do 
      login_as :quentin
    
      post :list
      assert_response :success
      assert_template 'list'
    end
  
    define_method('test: エラーコード編集画面を表示する') do 
      login_as :quentin
    
      post :edit, :id => 1 # base_ng_word = 1 を編集する
      assert_response :success
      assert_template 'edit'
    end
  
    define_method('test: エラーコード編集確認画面を表示する') do 
      login_as :quentin
    
      post :update_confirm, :id => 1, :base_error => { :error_code => 'U-00001', :message => '申し訳ございません。ページが見つかりません。', :coping => 'update edited'}
      assert_response :success
      assert_template 'update_confirm'
    end
  
    define_method('test: エラーコード編集処理実行') do 
      login_as :quentin
    
      post :update, :id => 1, :base_eror => { :eror_code => 'U-00001', :coping => 'edited'}
      assert_response :redirect 
      assert_redirected_to :action => 'list'
    
      base_error = BaseError.find_by_id(1)
      assert_not_nil(base_error) 
      assert_equal(base_error.error_code, 'U-00001')
    end
  
    define_method('test: エラーコード編集処理実行をキャンセル') do 
      login_as :quentin
    
      post :update, :id => 1, :base_error => { :error_code => '00009', :coping => 'cancel'}, :cancel => 'true'
      assert_response :success
      assert_template 'edit'
    
      base_error = BaseError.find_by_id(1)
      assert_not_nil(base_error) 
      assert_equal(base_error.error_code, 'U-00001') # cancelされているので変更されてない
    end
  
  end
end