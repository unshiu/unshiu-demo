require File.dirname(__FILE__) + '/../../test_helper'

module Manage
  module PrfControllerTestModule
  
    class << self
      def included(base)
        base.class_eval do
          include TestUtil::Base::PcControllerTest
          fixtures :base_users
          fixtures :base_friends
          fixtures :prf_question_sets  
          fixtures :prf_question_set_partials  
          fixtures :prf_questions
          fixtures :prf_choices
        end
      end
    end

    define_method('test: プロフィール管理トップ画面を表示する') do 
      login_as :quentin
    
      post :index
      assert_response :success
      assert_template 'index'
    end
  
    define_method('test: プロフィール質問項目新規登録画面を表示する') do 
      login_as :quentin
    
      post :new
      assert_response :success
      assert_template 'new'
    end
  
    define_method('test: プロフィール質問項目編集画面を表示する') do 
      login_as :quentin
    
      post :edit, :id => 1
      assert_response :success
      assert_template 'edit'
    end
  
    define_method('test: プロフィール質問項目編集確認画面を表示する') do 
      login_as :quentin
    
      post :edit_confirm, :id => 1, 
                          :question => { :prf_profile_id => 1,
                                         :question_type => 1, 
                                         :body => 'プロフィール項目編集確認画面を表示する', 
                                         :active_flag => true}
      assert_response :success
      assert_template 'edit_confirm'
    end
  
    define_method('test: プロフィール質問項目編集確認画面で本文が未入力なので入力画面へ戻る') do 
      login_as :quentin
    
      post :edit_confirm, :id => 1, 
                          :question => { :prf_profile_id => 1,
                                         :question_type => 1, 
                                         :body => '', 
                                         :active_flag => true}
      assert_response :success
      assert_template 'edit'
    end
  
    define_method('test: プロフィール質問項目編集実行をする') do 
      login_as :quentin
    
      # TODO updateのがいいよね
      post :edit_complete, :id => 1, 
                          :question => { :prf_profile_id => 1,
                                         :question_type => 1, 
                                         :body => 'プロフィール質問項目編集実行をする', 
                                         :active_flag => true}
      assert_response :redirect
      assert_redirected_to :action => 'index'
    
      prf_question = PrfQuestion.find_by_id(1)
      assert_equal prf_question.body, "プロフィール質問項目編集実行をする" # 更新実行されている
    end
  
    define_method('test: edit_complete はキャンセルボタンを押されるとプロフィール質問項目編集実行せずに編集画面へ戻る') do 
      login_as :quentin
    
      post :edit_complete, :id => 1, :question => { :prf_profile_id => 1, :question_type => 1,
                                                    :body => 'プロフィール質問項目編集実行をする', :active_flag => true},
                                     :cancel => "true"
      assert_response :success
      assert_template 'edit'
    
      prf_question = PrfQuestion.find_by_id(1)
      assert_not_equal prf_question.body, "" # 更新実行されていない
    end
    
    define_method('test: プロフィール質問選択肢の編集画面を表示する') do 
      login_as :quentin
    
      post :edit_choice, :id => 1
      assert_response :success
      assert_template 'edit_choice'
    end
  
    define_method('test: プロフィール質問選択肢の編集確認画面を表示する') do 
      login_as :quentin
    
      post :edit_choice_confirm, :prf_choice => { :id => 1, :prf_question_id => 1, :prf_profile_id => 1, 
                                                  :body => 'プロフィール質問選択肢の編集確認画面を表示する', :free_area_type => 0}
      assert_response :success
      assert_template 'edit_choice_confirm'
    end
  
    define_method('test: プロフィール質問選択肢の編集確認画面を表示しようとするが本文が未入力なので編集画面へ遷移する') do 
      login_as :quentin
    
      post :edit_choice_confirm, :prf_choice => { :id => 1, :prf_question_id => 1, :prf_profile_id => 1, 
                                                  :body => '', :free_area_type => 0}
      assert_response :success
      assert_template 'edit_choice'
    end
  
    define_method('test: プロフィール質問選択肢の編集を実行する') do 
      login_as :quentin
    
      post :edit_choice_update, :id => 1, 
                                :prf_choice => { :prf_question_id => 1, :prf_profile_id => 1, 
                                                 :body => 'プロフィール質問選択肢の編集を実行する', :free_area_type => 0}
      assert_response :redirect
      assert_redirected_to :action => 'choices' # 選択肢一覧画面へ
    
      prf_choice = PrfChoice.find_by_id(1)
      assert_equal prf_choice.body, "プロフィール質問選択肢の編集を実行する" # 更新実行されている
    end
  
    define_method('test: edit_choice_update はキャンセルボタンを押されると編集画面を表示する') do 
      login_as :quentin
    
      post :edit_choice_update, :id => 1, 
                                :prf_choice => { :prf_question_id => 1, :prf_profile_id => 1, 
                                                 :body => 'プロフィール質問選択肢の編集を実行する', :free_area_type => 0},
                                :cancel => "true"
      assert_response :success
      assert_template 'edit_choice'
      
      prf_choice = PrfChoice.find_by_id(1)
      assert_not_equal prf_choice.body, "プロフィール質問選択肢の編集を実行する" # 更新実行されていない
    end
    
    define_method('test: プロフィール質問選択肢の編集を実行しようとするがパラメータに問題があったため編集画面へ戻る') do 
      login_as :quentin
    
      post :edit_choice_update, :id => 1, 
                                :prf_choice => { :prf_question_id => 1, :prf_profile_id => 1, 
                                                 :body => '', :free_area_type => 0}
      assert_response :redirect
      assert_redirected_to :action => 'edit_choice' # 編集画面へ
    
      prf_choice = PrfChoice.find_by_id(1)
      assert_equal prf_choice.body, "男性" # 更新実行されていない
    end
    
    define_method('test: プロフィール質問選択肢一覧画面を表示する') do 
      login_as :quentin
    
      post :choices, :id => 1
      assert_response :success
      assert_template 'choices'
    end
  
    define_method('test: confirm はプロフィール質問の新規作成確認画面を表示する') do 
      login_as :quentin
    
      post :confirm, :question => { :prf_profile_id => 1, :question_type => 1, 
                                   :body => 'プロフィール質問を新規作成する', :active_flag => true}
      assert_response :success
      assert_template 'confirm'
    end
    
    define_method('test: confirm は入力内容に問題があったら新規作成画面を再度表示しエラーを通知する') do 
      login_as :quentin
    
      post :confirm, :question => { :prf_profile_id => 1, :question_type => 1, 
                                   :body => '', :active_flag => true}
      assert_response :success
      assert_template "new"
      
      prf_question = PrfQuestion.find(:first, :conditions => ["body = ''"])
      assert_nil prf_question # 作成されていない
    end
    
    define_method('test: プロフィール質問を新規作成する') do 
      login_as :quentin
    
      post :create, :question => { :prf_profile_id => 1, :question_type => 1, 
                                   :body => 'プロフィール質問を新規作成する', :active_flag => true}
      assert_response :redirect
      assert_redirected_to :action => 'choices' # 選択肢をもつ質問なので選択肢編集画面へ
    
      prf_question = PrfQuestion.find(:first, :conditions => ["body = 'プロフィール質問を新規作成する'"])
      assert_not_nil prf_question # 作成されている
    end
  
    define_method('test: create は自由回答のみのプロフィール質問を新規作成する') do 
      login_as :quentin
    
      # question_type = テキスト入力
      post :create, :question => { :prf_profile_id => 1, :question_type => 4, 
                                   :body => 'プロフィール質問を新規作成する', :active_flag => true}
      assert_response :redirect
      assert_redirected_to :action => 'index' # プロフィール管理トップ画面へ
    
      prf_question = PrfQuestion.find(:first, :conditions => ["body = 'プロフィール質問を新規作成する'"])
      assert_not_nil prf_question # 作成されている
      assert_equal prf_question.question_type, 4
    end
  
    define_method('test: create はキャセルボタンを押されたら新規作成画面を表示する') do 
      login_as :quentin
    
      post :create, :question => { :prf_profile_id => 1, :question_type => 4, 
                                   :body => 'プロフィール質問を新規作成する', :active_flag => true},
                    :cancel => "true"
                    
      assert_response :success
      assert_template "new"
      
      prf_question = PrfQuestion.find(:first, :conditions => ["body = 'プロフィール質問を新規作成する'"])
      assert_nil prf_question # 作成されていない
    end
    
    define_method('test: create_choice_confirm はプロフィール質問選択肢の作成の確認をする') do 
      login_as :quentin
    
      post :create_choice_confirm, :id => 1, 
                                   :choice => [
                                        { :prf_question_id => 1, :prf_profile_id => 1, :body => 'プロフィール質問選択肢の作成の実行をする1', :free_area_type => 0},
                                        { :prf_question_id => 1, :prf_profile_id => 1, :body => 'プロフィール質問選択肢の作成の実行をする2', :free_area_type => 0},
                                   ]
      assert_response :success
      assert_template "create_choice_confirm"
      
      prf_choice = PrfChoice.find(:first, :conditions => ["body = 'プロフィール質問選択肢の作成の実行をする1'"])
      assert_nil prf_choice # 追加実行されていない
    end
    
    define_method('test: create_choice_confirm は選択肢情報が空なら入力画面へ戻る') do 
      login_as :quentin
    
      post :create_choice_confirm, :id => 1, 
                                   :choice => [
                                        { :prf_question_id => 1, :prf_profile_id => 1, :body => '', :free_area_type => 0}
                                   ]
      assert_response :success
      assert_template "choices"
    end
    
    define_method('test: プロフィール質問選択肢の作成の実行をする') do 
      login_as :quentin
    
      post :create_choice, :id => 1, 
                           :choice => [
                                        { :prf_question_id => 1, :prf_profile_id => 1, :body => 'プロフィール質問選択肢の作成の実行をする1', :free_area_type => 0},
                                        { :prf_question_id => 1, :prf_profile_id => 1, :body => 'プロフィール質問選択肢の作成の実行をする2', :free_area_type => 0},
                                      ]
      assert_response :redirect
      assert_redirected_to :action => 'choices'
    
      prf_choice = PrfChoice.find(:first, :conditions => ["body = 'プロフィール質問選択肢の作成の実行をする1'"])
      assert_not_nil prf_choice # 追加実行されている
    end
  
    define_method('test: create_choice はキャンセルポタンを押したらプロフィール質問選択肢の作成のキャンセルをする') do 
      login_as :quentin
    
      post :create_choice, :id => 1, 
                           :choice => [
                                        { :prf_question_id => 1, :prf_profile_id => 1, :body => 'プロフィール質問選択肢の作成の実行をする1', :free_area_type => 0},
                                        { :prf_question_id => 1, :prf_profile_id => 1, :body => 'プロフィール質問選択肢の作成の実行をする2', :free_area_type => 0},
                                      ],
                           :cancel => "true"
      assert_response :success
      assert_template "choice"
      
      prf_choice = PrfChoice.find(:first, :conditions => ["body = 'プロフィール質問選択肢の作成の実行をする1'"])
      assert_nil prf_choice # 追加実行されていない
    end
    
    define_method('test: プロフィール質問の削除の確認画面を表示する') do 
      login_as :quentin
    
      post :delete_question_confirm, :id => 1
      assert_response :success
      assert_template 'delete_question_confirm'
    end
  
    define_method('test: プロフィール質問の削除の実行をする') do 
      login_as :quentin
    
      # TODO _completeいらないね
      post :delete_question_complete, :id => 1
      assert_response :redirect
      assert_redirected_to :action => 'index' # 削除後はトップへ遷移
    
      prf_question = PrfQuestion.find_by_id(1)
      assert_nil prf_question
    end
  
    define_method('test: delete_question_complete はキャンセルボタンを押されたらプロフィール質問の削除の実行をせず詳細画面へ戻る') do 
      login_as :quentin
    
      post :delete_question_complete, :id => 1, :cancel => 'true'
      assert_response :redirect
      assert_redirected_to :action => 'choices', :id => 1
    
      prf_question = PrfQuestion.find_by_id(1)
      assert_not_nil prf_question # 削除されていない
    end
    
    define_method('test: 質問の順番を下に移動する変更する') do 
      login_as :quentin
    
      post :move_question, :num => "2", :type => "-1"
      assert_response :redirect
      assert_redirected_to :action => 'index' # 削除後はトップへ遷移
    
      prf_question_set_parial = PrfQuestionSetPartial.find(:first, :conditions => ['prf_question_set_id = 1 and prf_question_id = 3'])
      assert_equal prf_question_set_parial.order_num, 1
      # TODO ajax にしたほうがいいよね
    end
  
    define_method('test: 質問の順番を上に移動する変更する') do 
      login_as :quentin
    
      post :move_question, :num => "2", :type => "1"
      assert_response :redirect
      assert_redirected_to :action => 'index' # 削除後はトップへ遷移
    
      prf_question_set_parial = PrfQuestionSetPartial.find(:first, :conditions => ['prf_question_set_id = 1 and prf_question_id = 3'])
      assert_equal prf_question_set_parial.order_num, 3
      # TODO ajax にしたほうがいいよね
    end
  
    define_method('test: プロフィール選択肢の削除確認画面を表示する') do 
      login_as :quentin
    
      post :delete_choice_confirm, :id => 1
      assert_response :success
      assert_template 'delete_choice_confirm'
    end
  
    define_method('test: プロフィール選択肢の削除を実行する') do 
      login_as :quentin
    
      post :delete_choice_complete, :id => 1
      assert_response :redirect
      assert_redirected_to :action => 'choices'
    
      prf_choice = PrfChoice.find_by_id(1)
      assert_nil prf_choice # 削除されている
    end
  
    define_method('test: delete_choice_complete はキャンセルボタンを押されたらプロフィール選択肢の削除を実行せずに選択肢一覧画面へ戻る') do 
      login_as :quentin
    
      post :delete_choice_complete, :id => 1, :cancel => true
      assert_response :redirect
      assert_redirected_to :action => 'choices', :id => 1
    
      prf_choice = PrfChoice.find_by_id(1)
      assert_not_nil prf_choice # 削除されていない
    end
    
  end
end