require File.dirname(__FILE__) + '/../test_helper'

module BaseProfileTestModule

  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::UnitTest
        fixtures :base_profiles
        fixtures :base_users
        fixtures :base_mail_dispatch_infos
      end
    end
  end

  define_method('test: 必須な情報はキーとなるbase_user_idだけでプロフィールが作成できる') do
    base_profile = BaseProfile.new({:base_user_id => 1})
    base_profile.save!
  end
  
  # 性別値から名称を取得するテスト
  def test_sex_kind_name
    assert !BaseProfile.sex_kind_name(1).blank?
    assert !BaseProfile.sex_kind_name(2).blank?
  end

  # 地域値から名称を取得するテスト
  def test_area_kind_name
    for value in 1..47
      assert !BaseProfile.area_kind_name(value).blank?
    end
  end
  
  define_method('test: 既婚・未婚値から名称を取得する') do 
    assert_not_nil(BaseProfile::CIVIL)
    assert !BaseProfile.civil_status_kind_name(1).blank?
    assert_equal(BaseProfile.civil_status_kind_name(1), "未婚")
    assert !BaseProfile.civil_status_kind_name(2).blank?
    assert_equal(BaseProfile.civil_status_kind_name(2), "既婚")
  end
  
  define_method('test: 画像が添付されたメールを受信し、プロフィール画像に設定する') do 
    email = read_mail_fixture('base_mailer_notifier', 'base_profile_receive')
    info = BaseMailDispatchInfo.find_by_mail_address(email.to.first)
    BaseProfile.receive(email, info)
    assert_equal '200804031851000.gif', BaseProfile.find(1).image_before_type_cast
  end
  
  define_method('test: 画像が２つ添付されたメールを受信したため、プロフィール画像は設定されない') do 
    email = read_mail_fixture('base_mailer_notifier', 'base_profile_double_receive')
    info = BaseMailDispatchInfo.find_by_mail_address(email.to.first)
    BaseProfile.receive(email, info)
    assert_nil BaseProfile.find(1).image
  end
  
  define_method('test: 動画が添付されたメールを受信したため、プロフィール画像は設定されない') do 
    email = read_mail_fixture('base_mailer_notifier', 'base_profile_movie_receive')
    info = BaseMailDispatchInfo.find_by_mail_address(email.to.first)
    BaseProfile.receive(email, info)
    assert_nil BaseProfile.find(1).image
  end
  
  define_method('test: 添付された画像のサイズが大きすぎるメールを受信したため、プロフィール画像は設定されない') do 
    email = read_mail_fixture('base_mailer_notifier', 'base_profile_bigger_receive')
    info = BaseMailDispatchInfo.find_by_mail_address(email.to.first)
    BaseProfile.receive(email, info)
    assert_nil BaseProfile.find(1).image
  end
  
  
  # サーバー環境（？）によって、数字8桁を Date に変換できないことがあるようなので　/ 付きに明示的に変換
  # が正常に動いているかのテスト attributes= 編
  def test_attributes_setter
    profile = BaseProfile.find(1)
    profile.birthday = nil # テストのため一旦 nil にします
    assert_nil profile.birthday
    
    # 8桁数字文字列を誕生日に設定してみる
    profile.attributes = {:birthday => '20080401'}
    assert_not_nil profile.birthday
    assert profile.birthday.is_a?(Date)
  end
  
  # サーバー環境（？）によって、数字8桁を Date に変換できないことがあるようなので　/ 付きに明示的に変換
  # が正常に動いているかのテスト birthday= 編
  def test_birthday_setter
    profile = BaseProfile.find(1)
    profile.birthday = nil # テストのため一旦 nil にします
    assert_nil profile.birthday
    
    # 8桁数字文字列を誕生日に設定してみる
    profile = BaseProfile.new
    profile.birthday = '20080401'
    assert_not_nil profile.birthday
    assert profile.birthday.is_a?(Date)
  end
  
  # ユーザーの name と同期できているのかテスト
  def test_after_save
    # プロフィール側で name　を変更して保存する
    profile = BaseProfile.find(1)
    profile.name = 'modified'
    profile.save
    
    # ユーザーを確認
    assert_equal 'modified', profile.base_user.name
  end
  
  define_method('test: 男性の数を取得する') do 
    before_count = BaseProfile.count_male
    base_profile = BaseProfile.find(1)
    base_profile.sex = 2 # 女性にするので男性数がへる
    base_profile.save
    
    assert_equal(BaseProfile.count_male, before_count - 1)
  end
  
  define_method('test: 女性の数を取得する') do 
    before_count = BaseProfile.count_female
    base_profile = BaseProfile.find(1)
    base_profile.sex = 2 # 女性にするので女性数がふえる
    base_profile.save
    
    assert_equal(BaseProfile.count_female, before_count + 1)
  end
  
  define_method('test: ユーザの登録地域数ごとの数を取得する') do 
    before_count = BaseProfile.count_area(30)
    base_profile = BaseProfile.find(1)
    base_profile.area = 30
    base_profile.save
    
    assert_equal(BaseProfile.count_area(30), before_count + 1)
  end
  
  define_method('test: 既婚者数を取得する') do 
    before_count = BaseProfile.count_married
    
    base_profile = BaseProfile.find(1)
    base_profile.civil_status = 2 # 既婚に設定
    base_profile.save
    
    assert_equal(BaseProfile.count_married, before_count + 1) # 既婚者数が増えている
  end
  
  define_method('test: 未婚者数を取得する') do 
    before_count = BaseProfile.count_unmarried
    
    base_profile = BaseProfile.find(1)
    base_profile.civil_status = 2 # 既婚に設定
    base_profile.save
    
    assert_equal(BaseProfile.count_unmarried, before_count - 1) # 未婚者数が減っている
  end
  
  define_method('test: validate によって問題のある誕生日日付が入力されたらvalidateエラーとする') do
    base_profile = BaseProfile.new({:birthday => "20050101"})
    assert_equal(base_profile.valid?, true)
    
    base_profile = BaseProfile.new({:birthday => "hogehoge"})
    assert_equal(base_profile.valid?, false)
    
    base_profile = BaseProfile.new({:birthday => ""})
    assert_equal(base_profile.valid?, true)
    
    base_profile = BaseProfile.new({:birthday => "44444444"})
    assert_equal(base_profile.valid?, false)
  end
  
end