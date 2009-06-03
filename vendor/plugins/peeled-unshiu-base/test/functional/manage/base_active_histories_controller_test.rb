module Manage::BaseActiveHistoriesControllerTestModule
  
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::PcControllerTest
        fixtures :base_users
        fixtures :base_user_roles
        fixtures :base_active_histories
      end
    end
  end
  
  define_method('test: アクティブ率一覧を表示する') do 
    login_as :quentin

    get :index
    assert_response :success
    assert_template "index"
    
    assert_not_nil assigns(:base_active_histories)
    assert_not_nil assigns('active_history_graph')
  end
  
  define_method('test: 3日前までにログイン胃歴のあるアクティブ率一覧を表示する') do 
    login_as :quentin

    get :index, :id => 3
    assert_response :success
    assert_template "index"
    
    assert_not_nil assigns(:base_active_histories)
    assigns(:base_active_histories).each do |base_active_history|
      assert_equal(base_active_history.before_days, 3)
    end
  end
  
  define_method('test: 7日前までにログイン胃歴のあるアクティブ率一覧を表示する') do 
    login_as :quentin

    get :index, :id => 7
    assert_response :success
    assert_template "index"
    
    assert_not_nil assigns(:base_active_histories)
    assigns(:base_active_histories).each do |base_active_history|
      assert_equal(base_active_history.before_days, 7)
    end
  end
  
  define_method('test: 3日前までにログイン胃歴のあるアクティブ率グラフを出力する') do 
    login_as :quentin

    get :active_history_graph, :before_days => 3
    assert_response :success
  end
end
