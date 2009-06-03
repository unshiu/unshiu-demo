require File.dirname(__FILE__) + '/../../test_helper'

module ManagePntImportControllerTestModule
  
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::PcControllerTest
        fixtures :base_users
        fixtures :base_user_roles
        fixtures :pnt_masters
        fixtures :pnt_points
        fixtures :pnt_history_summaries
      end
    end
  end

  define_method('test: 一括登録画面を表示') do 
    login_as :quentin
    
    post :new
    assert_response :success
    assert_template 'new'
  end
  
  define_method('test: 一括登録確認画面を表示') do 
    login_as :quentin
    
    post :confirm
    assert_response :success
    assert_template 'confirm'
  end
  
  define_method('test: 登録履歴一覧ページを表示') do 
    login_as :quentin
    
    post :list
    assert_response :success
    assert_template 'list'
  end
  
  define_method('test: ファイルアップロードのテスト') do 
    login_as :quentin
    test_file = "#{RAILS_ROOT}/test/file/pnt_import_csv_test.txt"
    
    post(:upload, :file => uploaded_file(test_file, 'text', 'pnt_import_controller_test'))
    
    assert_response :success
    assert_template 'confirm'
  end
  
  define_method('test: ファイル名が日本語でも不具合が生じないかどうかのテスト') do 
    login_as :quentin
    test_file = "#{RAILS_ROOT}/test/file/pnt_import_csv_test.txt"
    
    post(:upload, :file => uploaded_file(test_file, 'text', '日本語のファイル名です'))
    
    assert_response :success
    assert_template 'confirm'
  end
  
  define_method('test: upload はレコードフォーマットに問題があるファイルがアップロードされたら登録画面でエラーを表示する') do 
    login_as :quentin
    test_file = "#{RAILS_ROOT}/test/file/pnt_import_csv_error_file.txt"
    
    post(:upload, :file => uploaded_file(test_file, 'text', 'pnt_import_csv_error_file'))
    
    assert_response :success
    assert_template 'new'
  end
  
  define_method('test: upload はファイルを指定されない場合は登録画面でエラーを表示する') do 
    login_as :quentin
    
    post(:upload, :file => nil)
    
    assert_response :success
    assert_template 'new'
  end
  
  define_method('test: 一括処理プロセスとして登録するテスト') do 
    # :add_process はバックグランド処理がかかわるのでここではテストしない
  end
end
