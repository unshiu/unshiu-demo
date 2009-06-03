
module Manage::BaseNoticeControllerTestModule

  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::PcControllerTest
        fixtures :base_users
        fixtures :base_notices
        fixtures :base_user_roles
      end
    end
  end

  define_method('test: ユーザへのお知らせ管理トップ画面を表示') do 
    login_as :quentin

    post :index
    assert_response :success
    assert_template 'list'
  end

  define_method('test: ユーザへのお知らせ一覧画面を表示') do 
    login_as :quentin

    post :list
    assert_response :success
    assert_template 'list'
  end

  define_method('test: ユーザへのお知らせ個別画面を表示') do 
    login_as :quentin

    post :show, :id => 1
    assert_response :success
    assert_template 'show'
  end

  define_method('test: ユーザへのお知らせ新規登録画面を表示') do 
    login_as :quentin

    post :new
    assert_response :success
    assert_template 'new'
  end

  define_method('test: confirm はユーザへのお知らせ新規登録確認画面を表示') do 
    login_as :quentin

    post :confirm, :base_notice => { :title => 'unitTestお知らせタイトル', :body => 'unitTestお知らせ本文',
                                     'start_datetime(1i)' => '2001' , 'start_datetime(2i)' => '10', 'start_datetime(3i)' => '10',
                                     'start_datetime(4i)' => '12' , 'start_datetime(5i)' => '10',
                                     'end_datetime(1i)' => '2008' , 'end_datetime(2i)' => '12', 'end_datetime(3i)' => '31',
                                     'end_datetime(4i)' => '1' , 'end_datetime(5i)' => '10' }
    assert_response :success
    assert_template 'confirm'
  end

  define_method('test: ユーザへのお知らせ新規登録確認画面を表示しようとするがタイトルが空欄なので登録画面を表示') do 
    login_as :quentin

    post :confirm, :base_notice => { :title => '', :body => 'unitTestお知らせ本文',
                                     'start_datetime(1i)' => '2001' , 'start_datetime(2i)' => '10', 'start_datetime(3i)' => '10',
                                     'end_datetime(1i)' => '2008' , 'end_datetime(2i)' => '12', 'end_datetime(3i)' => '31' }
    assert_response :success
    assert_template 'new'
  end

  define_method('test: confirm は開始日付と終了日付が逆だったら編集画面へ戻りエラーを表示する') do 
    login_as :quentin

    post :confirm, :base_notice => { :title => 'unitTestお知らせタイトル', :body => 'unitTestお知らせ本文',
                                     'start_datetime(1i)' => '2011' , 'start_datetime(2i)' => '10', 'start_datetime(3i)' => '10',
                                     'end_datetime(1i)' => '2008' , 'end_datetime(2i)' => '12', 'end_datetime(3i)' => '31' }
    assert_response :success
    assert_template 'new'
  end

  define_method('test: create はユーザへのお知らせ新規登録実行をする') do 
    login_as :quentin

    post :create, :base_notice => { :title => 'unitTestお知らせタイトル', :body => 'unitTestお知らせ本文', 
                                    'start_datetime(1i)' => '2001' , 'start_datetime(2i)' => '10', 'start_datetime(3i)' => '10',
                                    'start_datetime(4i)' => '12' , 'start_datetime(5i)' => '10',
                                    'end_datetime(1i)' => '2008' , 'end_datetime(2i)' => '12', 'end_datetime(3i)' => '31',
                                    'end_datetime(4i)' => '1' , 'end_datetime(5i)' => '10'}
    assert_response :redirect 
    assert_redirected_to :action => 'list'

    base_notice = BaseNotice.find(:first, :conditions => [" title = 'unitTestお知らせタイトル'"])
    assert_not_nil(base_notice) # 作成されている
  end

  define_method('test: ユーザへのお知らせ新規登録実行をキャンセル') do 
    login_as :quentin

    post :create, :base_notice => { :title => 'unitTestお知らせタイトル', :body => 'unitTestお知らせ本文',
                                    'start_datetime(1i)' => '2001' , 'start_datetime(2i)' => '10', 'start_datetime(3i)' => '10',
                                    'end_datetime(1i)' => '2008' , 'end_datetime(2i)' => '12', 'end_datetime(3i)' => '31' },
                  :cancel => 'true'
          
    assert_response :success
    assert_template 'new'

    base_notice = BaseNotice.find(:first, :conditions => [" title = 'unitTestお知らせタイトル'"])
    assert_nil(base_notice) # 作成されていない
  end

  define_method('test: ユーザへのお知らせ更新画面を表示') do 
    login_as :quentin

    post :edit, :id => 1
    assert_response :success
    assert_template 'edit'
  end

  define_method('test: update_confirm はユーザへのお知らせ更新確認画面を表示する') do 
    login_as :quentin

    post :update_confirm, :id => 1,
                          :base_notice => { :title => 'unitTestお知らせタイトル', :body => 'unitTestお知らせ本文',
                                            'start_datetime(1i)' => '2001' , 'start_datetime(2i)' => '10', 'start_datetime(3i)' => '10',
                                            'start_datetime(4i)' => '12' , 'start_datetime(5i)' => '10',
                                            'end_datetime(1i)' => '2008' , 'end_datetime(2i)' => '12', 'end_datetime(3i)' => '31',
                                            'end_datetime(4i)' => '1' , 'end_datetime(5i)' => '10' }
    assert_response :success
    assert_template 'update_confirm'
  end

  define_method('test: ユーザへのお知らせ更新確認画面を表示しようとするが、タイトルが空だったので登録画面へ戻る') do 
    login_as :quentin

    post :update_confirm, :id => 1,
                          :base_notice => { :title => '', :body => 'unitTestお知らせ本文',
                                            'start_datetime(1i)' => '2001' , 'start_datetime(2i)' => '10', 'start_datetime(3i)' => '10',
                                            'end_datetime(1i)' => '2008' , 'end_datetime(2i)' => '12', 'end_datetime(3i)' => '31' }
    assert_response :success
    assert_template 'edit'
  end

  define_method('test: update はユーザへのお知らせ更新処理実行') do 
    login_as :quentin

    post :update, :id => 1,
                  :base_notice => { :title => 'unitTestお知らせタイトル', :body => 'unitTestお知らせ本文',
                                    'start_datetime(1i)' => '2001' , 'start_datetime(2i)' => '10', 'start_datetime(3i)' => '10',
                                    'start_datetime(4i)' => '12' , 'start_datetime(5i)' => '10',
                                    'end_datetime(1i)' => '2008' , 'end_datetime(2i)' => '12', 'end_datetime(3i)' => '31',
                                    'end_datetime(4i)' => '1' , 'end_datetime(5i)' => '10' }

    assert_response :redirect 
    assert_redirected_to :action => 'list'

    base_notice = BaseNotice.find_by_id(1)
    assert_not_nil(base_notice) 
    assert_equal(base_notice.title, 'unitTestお知らせタイトル') # 更新されている
  end

  define_method('test: ユーザへのお知らせ更新処理実行しようとするが、本文が空だったので編集画面へ戻る') do 
    login_as :quentin

    post :update, :id => 1,
                  :base_notice => { :title => 'unitTestお知らせタイトル', :body => '',
                                    'start_datetime(1i)' => '2001' , 'start_datetime(2i)' => '10', 'start_datetime(3i)' => '10',
                                    'end_datetime(1i)' => '2008' , 'end_datetime(2i)' => '12', 'end_datetime(3i)' => '31' }

    assert_response :success 
    assert_template 'edit'

    base_notice = BaseNotice.find_by_id(1)
    assert_not_equal(base_notice.title, 'unitTestお知らせタイトル') # 更新されていない
  end

  define_method('test: ユーザへのお知らせ更新処理実行のキャンセル') do 
    login_as :quentin

    post :update, :id => 1,
                  :base_notice => { :title => 'unitTestお知らせタイトル', :body => 'unitTestお知らせ本文',
                                    'start_datetime(1i)' => '2001' , 'start_datetime(2i)' => '10', 'start_datetime(3i)' => '10',
                                    'end_datetime(1i)' => '2008' , 'end_datetime(2i)' => '12', 'end_datetime(3i)' => '31' },
                  :cancel => 'true'

    assert_response :success 
    assert_template 'edit'

    base_notice = BaseNotice.find_by_id(1)
    assert_not_equal(base_notice.title, 'unitTestお知らせタイトル') # 更新されていない
  end

  define_method('test: ユーザへのお知らせ削除確認画面を表示') do 
    login_as :quentin

    post :delete_confirm, :id => 1
    assert_response :success
    assert_template 'delete_confirm'
  end

  define_method('test: ユーザへのお知らせ削除実行') do 
    login_as :quentin

    post :delete, :id => 1
    assert_response :redirect 
    assert_redirected_to :action => 'list'

    base_notice = BaseNotice.find_by_id(1)
    assert_nil(base_notice) # 削除されている
  end

  define_method('test: ユーザへのお知らせ削除実行のキャンセル') do 
    login_as :quentin

    post :delete, :id => 1, :cancel => 'true'
    assert_response :redirect 
    assert_redirected_to :action => 'show'

    base_notice = BaseNotice.find_by_id(1)
    assert_not_nil(base_notice.title) # キャンセルされたので削除されていない
  end
  
end