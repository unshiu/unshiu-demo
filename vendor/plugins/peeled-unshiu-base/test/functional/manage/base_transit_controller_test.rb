
module Manage::BaseTransitControllerTestModule
    
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::PcControllerTest
        fixtures :base_users
        fixtures :base_profiles
        fixtures :base_carriers
        fixtures :base_user_roles
      end
    end
  end
  
  define_method('test: 日単位のユーザー入退会数遷移情報を表示') do 
    login_as :quentin

    for i in 1..10
      s = sprintf("%.6d", i).to_s
      email = "#{s}@test.drecom.jp"
      joined_at = Time.mktime(2008,1,3,0,0,1)
      
      quitted_at = nil
      status = 2
      if i % 2 == 1 
        quitted_at = Time.mktime(2008,1,3,0,0,1)
        status = 4
      end

      user = BaseUser.new({:login => email, :email => email, :password => 'test',
                           :salt => '7e3041ebc2fc05a40c60028e2c4901a81035d3cd', :status => status, :joined_at => joined_at,
                           :quitted_at => quitted_at, :base_carrier_id => rand(4), :name => email})

      user.make_activation_code                     
      user.save
    end
    
    post :user, :type => "day",
                :date => { "start(1i)" => "2008", "start(2i)" => "01", "start(3i)" => "01", 
                           "end(1i)" => "2008", "end(2i)" => "02", "end(3i)" => "01"}
    assert_response :success
    assert_template 'user'
    
    assert_not_nil(assigns(:infos))
    assert_equal(assigns(:infos).size, 32)
    
    assigns(:infos).each_with_index do |info,index|
      if index > 1
        assert_equal(info[:all], 5)
      else
        assert_equal(info[:all], 0)
      end
      
      if index == 2
        assert_equal(info[:join], 10)
        assert_equal(info[:quit], 5)  
      else
        assert_equal(info[:join], 0)
        assert_equal(info[:quit], 0)
      end
    end
  end

  define_method('test: 月単位のユーザー入退会数情報を表示') do 
    login_as :quentin

    for i in 1..60
      month = i % 3 + 1
      s = sprintf("%.6d", i).to_s
      email = "#{s}@test.drecom.jp"
      joined_at = Time.mktime(2008,month,3,0,0,1)
      
      quitted_at = nil
      status = 2
      if i % 2 == 1 
        quitted_at = Time.mktime(2008,month,3,0,0,1)
        status = 4
      end

      user = BaseUser.new({:login => email, :email => email, :password => 'test',
                           :salt => '7e3041ebc2fc05a40c60028e2c4901a81035d3cd', :status => status, :joined_at => joined_at,
                           :quitted_at => quitted_at, :base_carrier_id => rand(4), :name => email})

      user.make_activation_code                     
      user.save
    end
    
    post :user, :type => "month",
                :date => { "start(1i)" => "2008", "start(2i)" => "01", "start(3i)" => "01", 
                           "end(1i)" => "2008", "end(2i)" => "03", "end(3i)" => "01"}
    assert_response :success
    assert_template 'user'
    
    assert_not_nil(assigns(:infos))
    assert_equal(assigns(:infos).size, 3)
    
    assigns(:infos).each_with_index do |info,index|
      assert_equal(info[:all], 10*(index+1)) # 毎月10づつ増加していく
      assert_equal(info[:join], 20)
      assert_equal(info[:quit], 10) 
    end
    
  end
  
  define_method('test: 日単位のユーザー入退会数情報グラフを表示') do 
    login_as :quentin
    
    post :transit_graph, :type => "day", :start_date => '2008/01/01', :end_date => '2008/04/01'
    assert_response :success
  end
  
  define_method('test: 月単位のユーザー入退会数情報グラフを表示') do 
    login_as :quentin
    
    post :transit_graph, :type => "month", :start_date => '2008/01/01', :end_date => '2008/04/01'
    assert_response :success
  end
  
  define_method('test: 日単位のユーザー数推移情報グラフを表示') do 
    login_as :quentin
    
    post :all_transit_graph, :type => "day", :start_date => '2008/01/01', :end_date => '2008/04/01'
    assert_response :success
  end
  
  define_method('test: 月単位のユーザー数推移情報グラフを表示') do 
    login_as :quentin
    
    post :all_transit_graph, :type => "month", :start_date => '2008/01/01', :end_date => '2008/04/01'
    assert_response :success
  end
  
  
  define_method('test: 日付が未入力で月単位のユーザー入退会数情報を表示') do 
    login_as :quentin

    post :user, :type => "month",
                 :date => { "start(1i)" => "2008", "start(2i)" => "01", "start(3i)" => "", 
                            "end(1i)" => "2008", "end(2i)" => "10", "end(3i)" => ""}
    assert_response :success
    assert_template 'user'
  end

  define_method('test: user は日単位のユーザー入退会数遷移情報を表示しようとするが終了日付が開始日付より前なので検索条件入力画面へ戻る') do 
    login_as :quentin

    post :user, :type => "day",
                :date => { "start(1i)" => "2008", "start(2i)" => "12", "start(3i)" => "01", 
                           "end(1i)" => "2008", "end(2i)" => "02", "end(3i)" => "01"}
    assert_response :success
    assert_template 'index'
  end

  define_method('test: user は日単位のユーザー入退会数遷移情報を表示しようとするが開始日付が未入力なので検索条件入力画面へ戻る') do 
    login_as :quentin

    post :user, :type => "day",
                :date => { "start(1i)" => "", "start(2i)" => "", "start(3i)" => "", 
                           "end(1i)" => "2008", "end(2i)" => "02", "end(3i)" => "01"}
    assert_response :success 
    assert_template 'index'
  end

  define_method('test: user は日単位のユーザー入退会数遷移情報を表示しようとするが開始日の日数が未入力なので検索条件入力画面へ戻る') do 
    login_as :quentin

    post :user, :type => "day",
                :date => { "start(1i)" => "2008", "start(2i)" => "12", "start(3i)" => "", 
                           "end(1i)" => "2008", "end(2i)" => "02", "end(3i)" => "01"}
    assert_response :success 
    assert_template 'index'
  end

  define_method('test: user は日単位のユーザー入退会数遷移情報を表示しようとするが終了日付が未入力なので検索条件入力画面へ戻る') do 
    login_as :quentin

    post :user, :type => "day",
                :date => { "start(1i)" => "2008", "start(2i)" => "12", "start(3i)" => "01", 
                           "end(1i)" => "", "end(2i)" => "", "end(3i)" => ""}
    assert_response :success 
    assert_template 'index'
  end

  define_method('test: user は日単位のユーザー入退会数遷移情報を表示しようとするが終了日付の日数が未入力なので検索条件入力画面へ戻る') do 
    login_as :quentin

    post :user, :type => "day",
                :date => { "start(1i)" => "2008", "start(2i)" => "12", "start(3i)" => "01", 
                           "end(1i)" => "2009", "end(2i)" => "01", "end(3i)" => ""}
    assert_response :success 
    assert_template 'index'
  end

  define_method('test: 日単位のユーザー入退会数遷移情報をcsvへ出力') do 
    login_as :quentin

    post :user, :type => "day",
                :date => { "start(1i)" => "2008", "start(2i)" => "01", "start(3i)" => "01", 
                           "end(1i)" => "2008", "end(2i)" => "02", "end(3i)" => "01"},
                :csv => 'true'
    assert_response :success
    # TODO csvファイルの出力の場合は？
  end

  define_method('test: 月単位のユーザー入退会数遷移情報をcsvへ出力') do 
    login_as :quentin

    post :user, :type => "month",
                :date => { "start(1i)" => "2008", "start(2i)" => "01", "start(3i)" => "01", 
                           "end(1i)" => "2008", "end(2i)" => "02", "end(3i)" => "01"},
                :csv => 'true'
    assert_response :success
    # TODO csvファイルの出力の場合は？
  end

end
