require File.dirname(__FILE__) + '/../test_helper'

module PrfProfileTestModule
  
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::UnitTest
        fixtures :prf_profiles
        fixtures :prf_questions
        fixtures :prf_question_sets
        fixtures :prf_question_set_partials
        fixtures :prf_choices
        fixtures :prf_answers
        fixtures :prf_images
        fixtures :base_users
        
        self.use_transactional_fixtures = false
      end
    end
  end

  # 関連付けのテスト
  def test_relation
    prf_profile = PrfProfile.find(1)
    assert_not_nil prf_profile.base_user
  end
  
  define_method('test: デフォルトプロフィールを作成する') do
    prf_profile = PrfProfile.new_default_profile({:base_user_id => 1})
    
    assert_not_nil prf_profile
    assert_equal(prf_profile.base_user_id, 1)
    assert_equal(prf_profile.public_level, 5) # デフォルでは自分に公開のみ
  end
  
  # プロフィールの回答を探すテスト
  def test_answer
    # 対象のプロフィールを取得
    profile = PrfProfile.find(1)
    
    # 対象の設問を取得
    question = PrfQuestion.find(1)
    
    # 回答の取得
    assert_not_nil answer = profile.answer(question)
    assert_equal 1, answer.prf_profile_id
    assert_equal 1, answer.prf_question_id
  end
  
  # プロフィールの回答を探すテスト（複数版）
  def test_answers
    # 対象のプロフィールを取得
    profile = PrfProfile.find(1)
    
    # 対象の設問を取得
    question = PrfQuestion.find(6)
    
    # 回答の取得
    assert_not_nil answers = profile.answers(question)
    assert_equal 2, answers.size
    assert_equal 1, answers[0].prf_profile_id
    assert_equal 6, answers[0].prf_question_id
    assert_equal 1, answers[1].prf_profile_id
    assert_equal 6, answers[1].prf_question_id
  end
  
  define_method('test: プロフィール画像を受信する') do
    # 事前確認：設定されていない
    prf_profile = PrfProfile.find(1)
    assert_nil prf_profile.prf_image_id 
    
    email = read_mail_fixture('base_mailer_notifier', 'prf_profile_receive')
    info = BaseMailDispatchInfo.find_by_mail_address(email.to.first)
    PrfProfile.receive(email, info)
    
    prf_profile = PrfProfile.find(1)
    assert_not_nil prf_profile.prf_image_id 
    assert_not_nil prf_profile.prf_image # 設定されている
  end
  
  define_method('test: プロフィール画像を受信しようとするが画像が大きすぎて追加されない') do
    
    email = read_mail_fixture('base_mailer_notifier', 'prf_profile_bigger_receive')
    info = BaseMailDispatchInfo.find_by_mail_address(email.to.first)
    PrfProfile.receive(email, info)
    
    prf_profile = PrfProfile.find(1)
    assert_nil prf_profile.prf_image_id # 設定されてない
  end
  
  define_method('test: プロフィール画像を受信しようとするが画像が２つ添付されていたため追加されない') do
    
    email = read_mail_fixture('base_mailer_notifier', 'prf_profile_double_receive')
    info = BaseMailDispatchInfo.find_by_mail_address(email.to.first)
    PrfProfile.receive(email,info)
    
    prf_profile = PrfProfile.find(1)
    assert_nil prf_profile.prf_image_id # 設定されてない
  end
  
  define_method('test: プロフィール画像を受信しようとするが動画が添付されていたため追加されない') do
    
    email = read_mail_fixture('base_mailer_notifier', 'prf_profile_movie_receive')
    info = BaseMailDispatchInfo.find_by_mail_address(email.to.first)
    PrfProfile.receive(email, info)
    
    prf_profile = PrfProfile.find(1)
    assert_nil prf_profile.prf_image_id # 設定されてない
  end
  
  # 非公開項目を含めたプロフィール検索のテスト
  def test_find_by_all_profile    
    PrfProfile.clear_index!
    PrfProfile.reindex!
    
    # 全件検索
    attrs = []
    profiles = PrfProfile.find_by_all_profile(nil, '', attrs)
    assert_not_nil profiles
    assert_equal 6, profiles.size
    
    # プロフィール回答による検索
    searches = {1 => 2} # prf_question_id = 1, prf_choice_id = 2 な回答を持つユーザー
    profiles = PrfProfile.find_by_all_profile(searches, '', attrs)
    assert_not_nil profiles
    assert_equal 2, profiles.size
    assert_equal 1, profiles[0].id
    assert_equal 2, profiles[1].id
    
    # メールアドレスによる検索
    attrs = ['mail STREQ mobilesns-dev@devml.drecom.co.jp']
    profiles = PrfProfile.find_by_all_profile(nil, '', attrs)
    assert_not_nil profiles
    assert_equal 1, profiles.size
    assert_equal 1, profiles[0].id
  end
  
  define_method('test: 公開プロフィールを検索する') do
    PrfProfile.clear_index!
    PrfProfile.reindex!
    
    # 全件検索
    attrs = []
    profiles = PrfProfile.find_by_public_profile(nil, '', attrs)
    assert_not_nil profiles
    assert_equal 6, profiles.size
    
    # プロフィール回答による検索
    searches = {1 => 2} # prf_question_id = 1, prf_choice_id = 2, public_level = PUBLIC_LEVEL_ALL の回答を持つユーザー
    profiles = PrfProfile.find_by_public_profile(searches, '', attrs)
    assert_not_nil profiles
    assert_equal 2, profiles.size
    
    searches = {6 => 12} 
    profiles = PrfProfile.find_by_public_profile(searches, '', attrs)
    assert_not_nil profiles
    assert_equal 1, profiles.size
  end
  
  # estraier 向け attribute_name を作るテスト
  def test_attr_names
    assert_nothing_raised do PrfProfile.question_id_attr_name(1) end
    assert_nothing_raised do PrfProfile.question_text_attr_name(1) end
    assert_nothing_raised do PrfProfile.question_public_level_attr_name(1) end
  end
  
  # document_object_with_include のテストは test_find_by_all_profile で代用
  
  # estraier 向け追加 attributes のテスト
  def test_options_attrs
    profile = PrfProfile.find(1)
    assert_nothing_raised do profile.optional_attrs end
  end
  
end
