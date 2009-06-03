
module AbmAlbumTestModule
  
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::UnitTest
        fixtures :base_users
        fixtures :base_friends
        fixtures :base_mail_dispatch_infos
        fixtures :base_mail_templates
        fixtures :base_mail_template_kinds
        fixtures :abm_albums
        fixtures :abm_images
      end
    end
  end
  
  define_method('test: リレーション') do
    abm_album = AbmAlbum.find(1)
    assert_not_nil abm_album.base_user
    assert_not_nil abm_album.abm_images
    assert_not_nil abm_album.cover_abm_image # アルバム表紙画像
  end
  
  define_method('test: 自分のアルバム一覧を取得する') do
    abm_albums = AbmAlbum.find_my_albums_with_pagenate(1, 10, 0) # base_user_id = 1のアルバム
    
    assert_not_nil(abm_albums)
    assert(abm_albums.size > 0)
    abm_albums.each do |abm_album|
      assert_equal(abm_album.base_user_id, 1)
    end
    
    abm_albums = AbmAlbum.find_my_albums_with_pagenate(999, 5, 0) 
    assert_not_nil(abm_albums) # 存在しない場合でもnilにはならない
    assert_equal(abm_albums.size, 0)
  end
  
  def test_find_accessible_albums
    owner_id = 1
    
    # 自分
    current_base_user = BaseUser.find(1)
    assert_equal 5, AbmAlbum.find_accessible_albums(current_base_user, owner_id).size
    
    # 友だち
    current_base_user = BaseUser.find(2)
    assert_equal 4, AbmAlbum.find_accessible_albums(current_base_user, owner_id).size
    
    # 友だちの友だち
    current_base_user = BaseUser.find(4)
    assert_equal 3, AbmAlbum.find_accessible_albums(current_base_user, owner_id).size
    
    # ログインユーザー
    current_base_user = BaseUser.find(3)
    assert_equal 2, AbmAlbum.find_accessible_albums(current_base_user, owner_id).size
    
    # ログインしていないユーザー
    current_base_user = :false
    assert_equal 1, AbmAlbum.find_accessible_albums(current_base_user, owner_id).size
  end
  
  def test_mine?
    # basic test
    album = AbmAlbum.find(1)
    assert ! album.mine?(3)
    assert ! album.mine?(2)
    assert album.mine?(1)
    
    # nil check
    assert !album.mine?(nil)
    
    # does not hit
    assert !album.mine?('hoge')
    assert !album.mine?('1')
    
    # basic test
    album = AbmAlbum.find(3)
    assert album.mine?(5)
    
    album = AbmAlbum.find 2
    assert ! album.mine?(1)
  end
  
  # 友だちのアルバム一覧のテスト
  def test_friend_albums
    # 対象ユーザー
    current_base_user = BaseUser.find(1)
    
    # 友だちのアルバム取得テスト
    albums = AbmAlbum.friend_albums(current_base_user)
    assert_not_nil albums
    
    # 友だちのユーザーID
    friend_user_ids = current_base_user.base_friends.collect{|friend| friend.friend_id}
    
    # 取得したアルバム作成者のユーザーID
    entry_user_ids = albums.collect{|album| album.base_user_id}.uniq
    
    # 作成者のユーザーIDが友だちのユーザーIDにすべて含まれていればOK
    assert_equal friend_user_ids, friend_user_ids | entry_user_ids
  end
  
  def test_valid?
    
    title_max = AppResources['base']['title_max_length']
    body_max  = AppResources['base']['body_max_length']
    
    album = AbmAlbum.new
    assert ! album.valid?

    album.title = "hoge"
    album.body = "hogehoge"
    album.public_level = UserRelationSystem::PUBLIC_LEVEL_ALL
    assert album.valid?
    
    # titleテスト
    album = AbmAlbum.new
    album.title = " "
    album.body = "hogehoge"
    album.public_level = UserRelationSystem::PUBLIC_LEVEL_ALL
    assert ! album.valid?

    album = AbmAlbum.new
    album.title = "あ" * title_max
    album.body = "hogehoge"
    album.public_level = UserRelationSystem::PUBLIC_LEVEL_ALL
    assert album.valid?
    
    album.title = "あ" * title_max + "あ"
    album.body = "hogehoge"
    assert ! album.valid?
    
    # bodyテスト
    album.title = "hoge"
    album.body = " "
    assert ! album.valid?
    
    album.title = "hoge"
    album.body = "あ" * body_max
    assert album.valid?
    
    album.title = "hoge"
    album.body = "あ" * body_max + "あ"
    assert ! album.valid?
    
    
    # public_levelテスト
    album.title = "hoge"
    album.body = "hogehoge"
    album.public_level = nil
    assert ! album.valid?
    
    album.title = "hoge"
    album.body = "hogehoge"
    album.public_level = "hoge"
    assert ! album.valid?
  end
  
  define_method('test: ユーザのアルバム容量を取得する') do
    sum_image_size = AbmAlbum.sum_image_size_by_base_user_id(1)
    
    result_image_size = 0
    albums = AbmAlbum.find(:all, :conditions => ['base_user_id = 1']) 
    albums.each do |album| # ユーザのアルバム一覧から画像一覧を取得し総容量を計算
      images = AbmImage.find(:all, :conditions => ['abm_album_id = ?', album.id])
      images.each do |image|
        result_image_size = result_image_size + image.image_size
      end
    end
    
    assert_equal(sum_image_size, result_image_size)
  end
  
  define_method('test: メールに添付された画像を保存する') do
    before_abm_image_count = AbmImage.count(:conditions => ['abm_album_id = 3'])
    
    # 添付処理実行
    email = read_mail_fixture('base_mailer_notifier', 'abm_album_receive')
    info = BaseMailDispatchInfo.find_by_mail_address(email.to.first)
    AbmAlbum.save_with_mail(email, info)
    
    after_abm_image_count = AbmImage.count(:conditions => ['abm_album_id = 3'])
    assert_equal(after_abm_image_count, before_abm_image_count + 1) # 1件増加している
    
    abm_image = AbmImage.find(:first, :conditions => ['abm_album_id = 3'], :order => ['created_at desc'])
    assert_equal(abm_image.title, "たいとる")
    assert_equal(abm_image.body, "テスト画像をアップしたよ\n")
  end
  
  define_method('test: メールに添付された画像を保存しようとするが画像が大きすぎるので保存されない') do
    before_abm_image_count = AbmImage.count(:conditions => ['abm_album_id = 3'])
    
    # 添付処理実行
    email = read_mail_fixture('base_mailer_notifier', 'abm_album_bigger_receive')
    info = BaseMailDispatchInfo.find_by_mail_address(email.to.first)
    AbmAlbum.save_with_mail(email,info)
    
    after_abm_image_count = AbmImage.count(:conditions => ['abm_album_id = 3'])
    assert_equal(after_abm_image_count, before_abm_image_count) # 増加していない
  end
  
  define_method('test: メールに添付された画像を保存しようとするが個人利用可能容量を超えるので保存されない') do
    before_abm_image_count = AbmImage.count(:conditions => ['abm_album_id = 3'])
    
    # 添付処理実行
    1.upto 7 do
      email = read_mail_fixture('base_mailer_notifier', 'abm_album_receive')
      info = BaseMailDispatchInfo.find_by_mail_address(email.to.first)
      AbmAlbum.save_with_mail(email,info)
    end
    
    after_abm_image_count = AbmImage.count(:conditions => ['abm_album_id = 3'])
    assert_equal(after_abm_image_count, before_abm_image_count + 7) # 7件増加している
    
    email = read_mail_fixture('base_mailer_notifier', 'abm_album_receive')
    info = BaseMailDispatchInfo.find_by_mail_address(email.to.first)
    AbmAlbum.save_with_mail(email,info)
    
    final_abm_image_count = AbmImage.count(:conditions => ['abm_album_id = 3'])
    assert_equal(after_abm_image_count, final_abm_image_count) # 増加していない
  end
  
  define_method('test: 個人利用容量制限がないのでメールに添付された画像は保存される') do
    AppResources[:abm][:user_size_max_image_size] = nil # 制限がない！
    
    before_abm_image_count = AbmImage.count(:conditions => ['abm_album_id = 3'])
    
    # 添付処理実行
    email = read_mail_fixture('base_mailer_notifier', 'abm_album_receive')
    info = BaseMailDispatchInfo.find_by_mail_address(email.to.first)
    AbmAlbum.save_with_mail(email, info)
    
    after_abm_image_count = AbmImage.count(:conditions => ['abm_album_id = 3'])
    assert_equal(after_abm_image_count, before_abm_image_count + 1) # 1件増加している
    
    # さらに添付処理実行
    email = read_mail_fixture('base_mailer_notifier', 'abm_album_receive')
    info = BaseMailDispatchInfo.find_by_mail_address(email.to.first)
    AbmAlbum.save_with_mail(email, info)
    
    final_abm_image_count = AbmImage.count(:conditions => ['abm_album_id = 3'])
    assert_equal(final_abm_image_count, after_abm_image_count + 1) # 1件増加している
    
    AppResources[:abm][:user_size_max_image_size] = "12K" # ほかのテストに影響があるので戻す
  end
  
  define_method('test: メールに添付された画像を保存しようとするがシステム利用可能容量を超えるので保存されない') do
    before_abm_image_count = AbmImage.count(:conditions => ['abm_album_id = 3'])
    before_abm_image_second_user_count = AbmImage.count(:conditions => ['abm_album_id = 2'])
    before_abm_image_last_user_count = AbmImage.count(:conditions => ['abm_album_id = 5'])
    
    # 添付処理実行
    1.upto 5 do
      email = read_mail_fixture('base_mailer_notifier', 'abm_album_receive')
      info = BaseMailDispatchInfo.find_by_mail_address(email.to.first)
      AbmAlbum.save_with_mail(email, info)
    end
    
    after_abm_image_count = AbmImage.count(:conditions => ['abm_album_id = 3'])
    assert_equal(after_abm_image_count, before_abm_image_count + 5) # 5件増加している
    
    # 別ユーザが添付処理実行
    1.upto 5 do 
      email = read_mail_fixture('base_mailer_notifier', 'abm_album_receive_2')
      info = BaseMailDispatchInfo.find_by_mail_address(email.to.first)
      AbmAlbum.save_with_mail(email, info)
    end
    
    after_abm_image_second_user_count = AbmImage.count(:conditions => ['abm_album_id = 2'])
    assert_equal(after_abm_image_second_user_count, before_abm_image_second_user_count + 5 ) # 5件増加している
    
    # さらに別ユーザが添付処理実行
    email = read_mail_fixture('base_mailer_notifier', 'abm_album_receive_3')
    info = BaseMailDispatchInfo.find_by_mail_address(email.to.first)
    AbmAlbum.save_with_mail(email, info)
    
    after_abm_image_last_user_count = AbmImage.count(:conditions => ['abm_album_id = 5'])
    assert_equal(after_abm_image_last_user_count, before_abm_image_last_user_count) # 増加していない
  end
  
  define_method('test: システム利用可能容量がない場合はメールに添付された画像はすべて保存される') do
    AppResources[:abm][:system_size_max_image_size] = nil # 制限がない！
    
    before_abm_image_count = AbmImage.count(:conditions => ['abm_album_id = 3'])
    before_abm_image_second_user_count = AbmImage.count(:conditions => ['abm_album_id = 2'])
    before_abm_image_last_user_count = AbmImage.count(:conditions => ['abm_album_id = 5'])
    
    # 添付処理実行
    email = read_mail_fixture('base_mailer_notifier', 'abm_album_receive')
    info = BaseMailDispatchInfo.find_by_mail_address(email.to.first)
    AbmAlbum.save_with_mail(email, info)
    
    after_abm_image_count = AbmImage.count(:conditions => ['abm_album_id = 3'])
    assert_equal(after_abm_image_count, before_abm_image_count + 1) # 1件増加している
    
    # 別ユーザが添付処理実行
    email = read_mail_fixture('base_mailer_notifier', 'abm_album_receive_2')
    info = BaseMailDispatchInfo.find_by_mail_address(email.to.first)
    AbmAlbum.save_with_mail(email,info)
    
    after_abm_image_second_user_count = AbmImage.count(:conditions => ['abm_album_id = 2'])
    assert_equal(after_abm_image_second_user_count, before_abm_image_second_user_count + 1 ) # 1件増加している
    
    # さらに別ユーザが添付処理実行
    email = read_mail_fixture('base_mailer_notifier', 'abm_album_receive_3')
    info = BaseMailDispatchInfo.find_by_mail_address(email.to.first)
    AbmAlbum.save_with_mail(email,info)
    
    after_abm_image_last_user_count = AbmImage.count(:conditions => ['abm_album_id = 5'])
    assert_equal(after_abm_image_last_user_count, before_abm_image_last_user_count + 1) # 1件増加している
    
    AppResources[:abm][:system_size_max_image_size] = "16K" # ほかのテストに影響があるので戻す
  end
  
  define_method('test: キャッシュされたアルバム一覧を取得する') do
    AbmAlbum.expire_cache("AbmAlbum#portal_public_albums") # テスト用にキャッシュ情報はクリアしておく
    AbmAlbum.record_timestamps = false
    
    before_abm_albums = AbmAlbum.cache_portal_public_albums # キャッシュ生成
    assert_equal(before_abm_albums.size, 3)
    
    # 全体公開のアルバムを作成
    abm_album = AbmAlbum.new({:base_user_id => 1, :public_level => UserRelationSystem::PUBLIC_LEVEL_ALL,
                              :title => "タイトル", :body => "ほんぶん", :updated_at => Time.now.tomorrow, :created_at => Time.now.tomorrow})
    abm_album.save!
    
    # キャッシュは更新されていない 
    cache_abm_albums = AbmAlbum.cache_portal_public_albums 
    assert_equal(cache_abm_albums.size, 3)
    0.upto(2) do |index| # Maxで3件しかとってこないのでidを比較
      assert_equal(before_abm_albums[index], cache_abm_albums[index])
    end
    
    public_abm_albums = AbmAlbum.public_albums # 実数は増えている
    assert_equal(public_abm_albums.size, 4)
    
    AbmAlbum.record_timestamps = true
  end
  
  define_method('test: キャッシュされたアルバム一覧はキャッシュ対象が削除されると情報をクリアする') do
    AbmAlbum.expire_cache("AbmAlbum#portal_public_albums") # テスト用にキャッシュ情報はクリアしておく
      
    public_abm_albums = AbmAlbum.public_albums 
    assert_equal(public_abm_albums.size, 3)
    
    
    # 全体公開のアルバム削除
    public_album = AbmAlbum.find(1)
    assert_equal(public_album.public_level, UserRelationSystem::PUBLIC_LEVEL_ALL) # 全体公開
    
    public_album.destroy!
    
    cache_abm_images = AbmAlbum.cache_portal_public_albums # キャッシュは更新されている
    assert_equal(cache_abm_images.size, 2)
    
    public_abm_images = AbmAlbum.public_albums # 実数ももちろん減っている
    assert_equal(public_abm_images.size, 2)
  end
  
  define_method('test: アルバムが削除されたがキャッシュ対象ではないので情報はクリアしない') do
    AbmAlbum.expire_cache("AbmAlbum#portal_public_albums") # テスト用にキャッシュ情報はクリアしておく
    AbmAlbum.record_timestamps = false 
    
    before_abm_albums = AbmAlbum.cache_portal_public_albums # キャッシュ生成
    assert_equal(before_abm_albums.size, 3)
    
    # 全体公開のアルバムを作成
    abm_album = AbmAlbum.new({:base_user_id => 1, :public_level => UserRelationSystem::PUBLIC_LEVEL_ALL,
                              :title => "タイトル", :body => "ほんぶん", :updated_at => Time.now.tomorrow})
    abm_album.save!
    
    abm_album = AbmAlbum.new({:base_user_id => 1, :public_level => UserRelationSystem::PUBLIC_LEVEL_ALL,
                              :title => "タイトル2", :body => "ほんぶん2", :updated_at => Time.now.tomorrow})
    abm_album.save!
    
    # キャッシュクリア対象外のアルバムを削除
    non_public_album = AbmAlbum.find(5)
    assert_not_equal(non_public_album.public_level, UserRelationSystem::PUBLIC_LEVEL_ALL) # 全体公開ではない
    
    non_public_album.destroy!
    
    # キャッシュは更新されていない
    cache_abm_albums = AbmAlbum.cache_portal_public_albums 
    assert_equal(cache_abm_albums.size, 3)
    0.upto(2) do |index| # Maxで3件しかとってこないのでidを比較
      assert_equal(before_abm_albums[index], cache_abm_albums[index])
    end
    
    public_abm_albums = AbmAlbum.public_albums # 実数は増加している
    assert_equal(public_abm_albums.size, 5)
    
    AbmAlbum.record_timestamps = true  
  end
end
