require File.dirname(__FILE__) + '/../test_helper'

module TpcCmmControllerMobileTestModule
  
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::MobileControllerTest
        fixtures :base_users
        fixtures :base_friends
        fixtures :tpc_topics
        fixtures :tpc_topic_cmm_communities
        fixtures :tpc_comments
      end
    end
  end
  
  define_method('test: コミュニティのトピック一覧を表示する') do
    login_as :aaron
    
    post :list, :id => 1 # cmm_community_id = 1 のコミュニティのトピック一覧
    assert_response :success
    assert_template 'list_mobile'
    
    assert_not_nil(assigns['topics'])
    assert_not_nil(assigns['community'])
  end
  
  define_method('test: コミュニティを空欄で検索し一覧を取得する') do
    login_as :aaron
    
    TpcTopicCmmCommunity.clear_index!
    TpcTopicCmmCommunity.reindex!
    
    post :search, :id => 1
    assert_response :success
    assert_template 'search_mobile'
    
    assert_not_nil(assigns['topics'])
    assert_not_nil(assigns['community'])
  end
  
  define_method('test: コミュニティを特定のキーワードで検索しその結果トピック一覧を表示する') do
    login_as :aaron
    
    TpcTopicCmmCommunity.clear_index!
    TpcTopicCmmCommunity.reindex!
    
    post :search, :id => 1, :keyword => 'test'
    assert_response :success
    assert_template 'search_mobile'
    
    assert_not_nil(assigns['topics'])
    assert_not_nil(assigns['community'])
  end
  
  define_method('test: トピック詳細画面を表示する') do
    login_as :aaron
    
    post :show, :id => 1 # tpc_topic_cmm_community = 1 のトピック詳細
    assert_response :success
    assert_template 'show_mobile'
    
    assert_not_nil(assigns['topic'])
    assert_not_nil(assigns['community'])
    assert_not_nil(assigns['comments'])
  end
  
  define_method('test: トピック詳細画面を表示しようとするが、参加者のみ公開のトピックのためエラーページへ遷移') do
    login_as :ten
    
    post :show, :id => 6
    assert_response :redirect
    assert_redirect_with_error_code "U-09001"
  end

  define_method('test: コメント件数が０件の場合に自分がコメントしたトピック一覧を表示する') do
    login_as :aaron
    
    post :commented_list
    assert_response :success
    assert_template 'commented_list_mobile'
    
    assert_not_nil(assigns['topics'])
  end
  
  define_method('test: コメント件数が１件以上ある場合に自分がコメントしたトピック一覧を表示する') do
    login_as :quentin
    
    post :commented_list
    assert_response :success
    assert_template 'commented_list_mobile'
    
    assert_not_nil(assigns['topics'])
  end
  
  define_method('test: 自分がコメントしたトピック一覧を表示しようとするがログインしていないのでログイン画面へ遷移する') do
    # login_as :aaron
    
    post :commented_list
    assert_response :redirect
    assert_redirected_to :controller => :base_user, :action => :login, :return_to => '/tpc_cmm/commented_list'
  end
  
  define_method('test: 所属コミュニティの最新トピック一覧を表示する') do
    login_as :aaron
    
    post :latest_list
    assert_response :success
    assert_template 'latest_list_mobile'
    
    assert_not_nil(assigns['topics'])
  end
  
  define_method('test: 所属してるコミュニティのトピック一覧を表示する') do
    login_as :aaron
    
    post :public_list
    assert_response :success
    assert_template 'public_list_mobile'
    
    assert_not_nil(assigns['topics'])
  end
  
  define_method('test: トピックコメント一覧を表示する') do
    login_as :aaron
    
    post :comments, :id => 1 # tpc_topic_cmm_community = 1 のコミュニティのトピックのコメント
    assert_response :success
    assert_template 'comments_mobile'
    
    assert_not_nil(assigns['topic'])
    assert_not_nil(assigns['comments'])
  end
  
  define_method('test: トピックコメント一覧を表示しようとするが、参加者のみ公開のトピックのためエラーページへ遷移') do
    login_as :ten
    
    post :comments, :id => 6
    assert_response :redirect
    assert_redirect_with_error_code "U-09001"
  end
  
  define_method('test: トピックコメントを新規作成する') do
    login_as :aaron
    
    post :new_comment, :id => 1, :comment => { :tpc_topic_id => 1 } # tpc_topic_id = 1 のトピックにコメント
    assert_response :success
    assert_template 'new_comment_mobile'
    
    assert_not_nil(assigns['topic'])
    assert_not_nil(assigns['comment'])
  end
  
  define_method('test: トピックコメントを新規作成しようとするが、公開されていないコミュニティのトピックのためエラーページへ遷移') do
    login_as :ten
    
    post :new_comment, :id => 6, :comment => { :tpc_topic_id => 6 } # tpc_topic_id = 6 のトピックにコメント
    assert_response :redirect
    assert_redirect_with_error_code "U-09002"
  end
  
  define_method('test: トピックコメントを新規作成の確認画面を表示する') do
    login_as :aaron
    
    post :comment_confirm, :id => 1, :comment => { :tpc_topic_id => 1, :body => "とぴっく！"}
    assert_response :success
    assert_template 'comment_confirm_mobile'
    
    assert_not_nil(assigns['topic'])
    assert_not_nil(assigns['comment'])
  end
  
  define_method('test: トピックコメントを新規作成の確認画面を表示しようとするが、本文が未入力だっため作成画面へ遷移する') do
    login_as :aaron
    
    post :comment_confirm, :id => 1, :comment => { :tpc_topic_id => 1, :body => ""}
    assert_response :success
    assert_template 'new_comment_mobile'
    
    assert_not_nil(assigns['topic'])
    assert_not_nil(assigns['comment'])
  end
  
  define_method('test: トピックコメントを新規作成を実行する') do
    login_as :aaron
    
    before_tpc_topic = TpcTopic.find_by_id(1)
    
    post :comment_complete, :id => 1, :comment => { :tpc_topic_id => 1, :body => "new test create comment!!!"}
    assert_response :redirect
    assert_redirected_to :action => :comment_done, :id => 1
    
    tpc_comment = TpcComment.find(:first, :conditions => ["body = 'new test create comment!!!'"])
    assert_not_nil(tpc_comment)
    
    # コメント最終日が更新されている
    assert_not_equal(before_tpc_topic.last_commented_at, tpc_comment.tpc_topic.last_commented_at)
  end
  
  define_method('test: トピックコメントを新規作成を実行のキャンセルする') do
    login_as :aaron
    
    before_tpc_topic = TpcTopic.find_by_id(1)
    
    post :comment_complete, :id => 1, :comment => { :tpc_topic_id => 1, :body => "new test create comment!!!"},
                            :cancel => 'true'
    assert_response :success
    assert_template 'new_comment_mobile'
    
    tpc_comment = TpcComment.find(:first, :conditions => ["body = 'new test create comment!!!'"])
    assert_nil(tpc_comment)
    
    # コメント最終日が更新されていない
    after_tpc_topic = TpcTopic.find_by_id(1)
    assert_equal(before_tpc_topic.last_commented_at, after_tpc_topic.last_commented_at)
  end
  
  define_method('test: トピックコメントを削除の確認画面を表示する') do
    login_as :aaron
    
    post :delete_comment_confirm, :id => 1 # tpc_comment_id = 1 のトピックコメントを削除
    assert_response :success
    assert_template 'delete_comment_confirm_mobile'
    
    assert_not_nil(assigns['topic'])
    assert_not_nil(assigns['comment'])
  end
  
  define_method('test: トピックコメントを削除の確認画面を表示しようとするが、管理者でもコメントした人でもないのでエラー画面へ遷移する') do
    login_as :three
    
    post :delete_comment_confirm, :id => 1 # tpc_comment_id = 1 のトピックコメントを削除
    assert_response :redirect
    assert_redirect_with_error_code "U-09004"
  end
  
  define_method('test: トピックコメントを削除実行をする') do
    login_as :aaron
    
    post :delete_comment_complete, :id => 1 # tpc_comment_id = 1 のトピックコメントを削除
    assert_response :redirect
    assert_redirected_to :action => :delete_comment_done, :id => 1
    
    tpc_comment = TpcComment.find_by_id(1)
    assert_not_nil(tpc_comment)
    assert_equal(tpc_comment.invisibled_by_anyone?, true)
  end
  
  define_method('test: トピックコメントを削除実行をキャンセル') do
    login_as :aaron
    
    post :delete_comment_complete, :id => 1, :cancel => 'true'
    assert_response :redirect
    assert_redirected_to :action => :show, :id => 1
    
    tpc_comment = TpcComment.find_by_id(1)
    assert_not_nil(tpc_comment)
    assert_equal(tpc_comment.invisibled_by_anyone?, false) # 削除されていない
  end
  
  define_method('test: トピック削除の確認画面を表示する') do
    login_as :aaron
    
    post :delete_confirm, :id => 1 # tpc_topic_cmm_community = 1 のコミュニティのトピックを削除
    assert_response :success
    assert_template 'delete_confirm_mobile'
    
    assert_not_nil(assigns['topic'])
  end
  
  define_method('test: トピック削除の確認画面を表示しようとするが、コミュニティ管理者ではないのでエラー画面へ遷移する') do
    login_as :three
    
    post :delete_confirm, :id => 1 # tpc_topic_cmm_community = 1 のコミュニティのトピックを削除
    assert_response :redirect
    assert_redirect_with_error_code "U-09003"
  end
  
  define_method('test: トピック削除の実行をする') do
    login_as :aaron
    
    post :delete_complete, :id => 1 # tpc_topic_cmm_community = 1 のコミュニティのトピックを削除
    assert_response :redirect
    assert_redirected_to :action => :delete_done, :id => 1
    
    tpc_topic_cmm_community = TpcTopicCmmCommunity.find_by_id(1)
    assert_nil(tpc_topic_cmm_community) # 削除されている
  end
  
  define_method('test: トピック削除の実行をキャンセルする') do
    login_as :aaron
    
    post :delete_complete, :id => 1, :cancel => 'true'
    assert_response :redirect
    assert_redirected_to :action => :show, :id => 1
    
    tpc_topic_cmm_community = TpcTopicCmmCommunity.find_by_id(1)
    assert_not_nil(tpc_topic_cmm_community) # 削除されていない
  end
end