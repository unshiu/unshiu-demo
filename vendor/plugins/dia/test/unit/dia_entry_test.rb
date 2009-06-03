require File.dirname(__FILE__) + '/../test_helper'

module DiaEntryTestModule
  
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::UnitTest
        fixtures :dia_diaries
        fixtures :dia_entries
        fixtures :dia_entry_comments
        fixtures :dia_entries_abm_images
        fixtures :abm_images
        fixtures :base_mail_dispatch_infos
        fixtures :abm_albums
      end
    end
  end
  
  # 関連付けのテスト
  def test_relation
    dia_entry = DiaEntry.find(1)
    assert_not_nil dia_entry.dia_diary
    assert_not_nil dia_entry.dia_entry_comments
    assert_not_nil dia_entry.dia_entries_abm_images
    assert_not_nil dia_entry.abm_images
  end

  define_method('test: receive はメールを受信する') do 
    count = DiaEntry.count # 現在の日記記事数
    
    # メール受信（タイトルと本文）
    raw_email = read_mail_fixture('base_mailer_notifier', 'dia_entry_receive')
    DiaEntry.receive(raw_email, BaseMailDispatchInfo.find(1))
    
    assert_equal count + 1, DiaEntry.count # 数の確認(1増えている)
  end
  
  define_method('test: receive は画像が添付されたメールを受信する') do 
    count = DiaEntry.count # 現在の日記記事数
    
    # メール受信(画像添付あり)
    raw_email = read_mail_fixture('base_mailer_notifier', 'dia_entry_with_image_receive')
    DiaEntry.receive(raw_email, BaseMailDispatchInfo.find(1))
    
    assert_equal count + 1, DiaEntry.count # 数の確認(1増えている)
    
    # 画像が関連付けられているかの確認
    assert_equal 1, DiaEntry.find(:first, :order => 'id desc').abm_images.size
  end
  
  define_method('test: receive は画像が添付されたメールにアルバムがなければ新規作成して保存する') do
    AbmAlbum.delete_all # 一旦削除してしまう
     
    count = DiaEntry.count # 現在の日記記事数
    
    # メール受信(画像添付あり)
    raw_email = read_mail_fixture('base_mailer_notifier', 'dia_entry_with_image_receive')
    DiaEntry.receive(raw_email, BaseMailDispatchInfo.find(1))
    
    assert_equal count + 1, DiaEntry.count # 数の確認(1増えている)
    
    # 画像が関連付けられているかの確認
    assert_equal 1, DiaEntry.find(:first, :order => 'id desc').abm_images.size
  end
  
  define_method('test: 画像以外添付されたメールの日記は更新しない') do 
    count = DiaEntry.count # 現在の日記記事数
    
    # メール受信(画像以外が添付)
    raw_email = read_mail_fixture('base_mailer_notifier', 'dia_entry_with_movie_receive')
    BaseMailerNotifier.receive(raw_email.to_s)
    
    assert_equal count, DiaEntry.count # 数の確認(増えていない)
  end
  
  define_method('test: 日記のvalidationにひっかかるような記事はは更新しない') do 
    count = DiaEntry.count # 現在の日記記事数
    
    # メール受信(validation error)
    raw_email = read_mail_fixture('base_mailer_notifier', 'dia_entry_without_body_receive')
    BaseMailerNotifier.receive(raw_email.to_s)
    
    assert_equal count, DiaEntry.count # 数の確認(増えていない)
  end
  
  define_method('test: friend_entries は友だちの日記記事で公開されているものを取得する') do 
    current_base_user = BaseUser.find(1)

    # 友だちのユーザーID
    friend_user_ids = current_base_user.base_friends.collect{|friend| friend.friend_id}
    
    dia_entry = DiaEntry.new({:dia_diary_id => DiaDiary.find_by_base_user_id(friend_user_ids[0]).id, 
                              :title => "test", :body => "test",
                              :public_level => UserRelationSystem::PUBLIC_LEVEL_ME})
    dia_entry.save! # ある友達の記事を自分にだけ公開にする
    
    entries = DiaEntry.friend_entries(current_base_user)
    assert_not_nil entries

    # 取得した日記投稿者のユーザーID
    entry_user_ids = entries.collect{|entry| entry.dia_diary.base_user_id}.uniq
    
    # 投稿者のユーザーIDが友だちのユーザーIDにすべて含まれていればOK
    assert_equal friend_user_ids, friend_user_ids | entry_user_ids
    
    entries.each do |entry|
      # ともだちが自分にだけ公開している記事は表示しない
      assert_not_equal(entry.public_level, UserRelationSystem::PUBLIC_LEVEL_ME)
    end
  end
  
  define_method('test: friend_entries は友だちの日記記事のうち下書きの記事は含まない') do 
    current_base_user = BaseUser.find(1)

    # 友だちのユーザーID
    friend_user_ids = current_base_user.base_friends.collect{|friend| friend.friend_id}
    
    dia_entry = DiaEntry.new({:dia_diary_id => DiaDiary.find_by_base_user_id(friend_user_ids[0]).id, 
                              :title => "draft_test", :body => "draft_test", :draft_flag => true,
                              :public_level => UserRelationSystem::PUBLIC_LEVEL_ALL})
    dia_entry.save! # ある友達の下書きを全体に公開にする
    
    entries = DiaEntry.friend_entries(current_base_user)
    assert_not_nil entries

    # 取得した日記投稿者のユーザーID
    entry_user_ids = entries.collect{|entry| entry.dia_diary.base_user_id}.uniq
    
    # 投稿者のユーザーIDが友だちのユーザーIDにすべて含まれていればOK
    assert_equal friend_user_ids, friend_user_ids | entry_user_ids
    
    entries.each do |entry|
      assert_equal(entry.draft_flag, false) # draft記事は取得されない
    end
  end
  
  # 全体に公開の日記記事一覧のテスト
  def test_public_entries
    # 全件取得テスト
    assert_equal 3, DiaEntry.public_entries.length
    
    # limit テスト
    assert_equal 2, DiaEntry.public_entries(:limit => 2).length
    
    # ページテスト
    entries = DiaEntry.public_entries(:page => {:size => 2, :current => nil}) # 1ページめ
    entries.load_page
    assert_equal 2, entries.results.length
    
    entries = DiaEntry.public_entries(:page => {:size => 2, :current => 2}) # 2ページめ
    entries.load_page
    assert_equal 1, entries.results.length
  end

  define_method('test: キャッシュした全体へ公開する記事一覧を取得する') do 
    DiaEntry.expire_cache("DiaEntry#portal_public_entries") # テスト用にキャッシュ情報はクリアしておく
    
    before_dia_entries = DiaEntry.cache_portal_public_entries # キャッシュ生成
    assert_equal(before_dia_entries.size, 3)
    
    # 全体公開の日記作成
    dia_entry = DiaEntry.new({:dia_diary_id => 1, :public_level => UserRelationSystem::PUBLIC_LEVEL_ALL,
                              :title => "タイトル", :body => "ほんぶん", :draft_flag => false, :contributed_at => Time.now.tomorrow})
    dia_entry.save!
    
    # キャッシュは更新されていない 
    cache_portal_public_entries = DiaEntry.cache_portal_public_entries 
    assert_equal(cache_portal_public_entries.size, 3)
    0.upto(2) do |index| # Maxで3件しかとってこないのでidを比較
      assert_equal(before_dia_entries[index].id, cache_portal_public_entries[index].id)
    end
    
    dia_etnries = DiaEntry.public_entries # 実数は増えている
    assert_equal(dia_etnries.size, 4)
  end
  
  define_method('test: キャッシュされた記事一覧はキャッシュ対象が削除されると情報をクリアする') do 
    DiaEntry.expire_cache("DiaEntry#portal_public_entries") # テスト用にキャッシュ情報はクリアしておく
    
    before_dia_entries = DiaEntry.cache_portal_public_entries # キャッシュ生成
    assert_equal(before_dia_entries.size, 3)
    
    # 全体公開の記事削除
    public_dia_entry = DiaEntry.find(1)
    assert_equal(public_dia_entry.public_level, UserRelationSystem::PUBLIC_LEVEL_ALL) # 全体公開
    
    public_dia_entry.destroy!
    
    cache_portal_public_entries = DiaEntry.cache_portal_public_entries # キャッシュは更新されている
    assert_equal(cache_portal_public_entries.size, 2)
    
    dia_entries = DiaEntry.public_entries # 実数ももちろん減っている
    assert_equal(dia_entries.size, 2)
  end
  
  define_method('test: 記事が削除されたがキャッシュ対象ではないので情報はクリアしない') do
    DiaEntry.expire_cache("DiaEntry#portal_public_entries") # テスト用にキャッシュ情報はクリアしておく
    
    before_dia_entries = DiaEntry.cache_portal_public_entries # キャッシュ生成
    assert_equal(before_dia_entries.size, 3)
    
    # 全体公開の日記作成
    dia_entry = DiaEntry.new({:dia_diary_id => 1, :public_level => UserRelationSystem::PUBLIC_LEVEL_ALL,
                              :title => "タイトル", :body => "ほんぶん", :draft_flag => false, :contributed_at => Time.now.tomorrow})
    dia_entry.save!
    
    # 全体公開の日記作成
    dia_entry = DiaEntry.new({:dia_diary_id => 1, :public_level => UserRelationSystem::PUBLIC_LEVEL_ALL,
                              :title => "タイトル", :body => "ほんぶん", :draft_flag => false, :contributed_at => Time.now.tomorrow})
    dia_entry.save!
    
    # キャッシュクリア対象外の記事を削除
    non_public_dia_entry = DiaEntry.find(2)
    assert_not_equal(non_public_dia_entry.public_level, UserRelationSystem::PUBLIC_LEVEL_ALL) # 全体公開ではない
    
    non_public_dia_entry.destroy!
    
    # キャッシュは更新されていない
    cache_dia_entries = DiaEntry.cache_portal_public_entries
    assert_equal(cache_dia_entries.size, 3)
    0.upto(2) do |index| # Maxで3件しかとってこないのでidを比較
      assert_equal(before_dia_entries[index].id, cache_dia_entries[index].id)
    end
    
    dia_entries = DiaEntry.public_entries # 実数は増加している
    assert_equal(dia_entries.size, 5)
  end
  
  # 全体に公開の日記記事キーワード検索のテスト
  def test_public_entries_keyword_search
    # インデックスの初期化
    DiaEntry.clear_index!
    DiaEntry.reindex!
    
    # 空の文字列および nil は全件探索
    assert_equal 3, DiaEntry.public_entries_keyword_search('').length
    assert_equal 3, DiaEntry.public_entries_keyword_search(nil).length
    
    # limit テスト
    assert_equal 1, DiaEntry.public_entries_keyword_search('テストタイトルA', :limit => 2).length
    
    # page テスト
    entries = DiaEntry.public_entries_keyword_search('テストタイトル', :page => {:size => 2, :current => nil})
    entries.load_page
    assert_equal 2, entries.results.length
    entries = DiaEntry.public_entries_keyword_search('テストタイトル', :page => {:size => 2, :current => 10})
    entries.load_page
    assert_equal 0, entries.results.length
  end
  
  # 下書きでない日記記事一覧のテスト
  def test_undraft_entries
    # 全件取得テスト
    assert_equal 7, DiaEntry.undraft_entries.length
    
    # limit テスト
    assert_equal 2, DiaEntry.undraft_entries(:limit => 2).length
    entries = DiaEntry.undraft_entries(:page => {:size => 2, :current => nil})
    entries.load_page
    assert_equal 2, entries.results.length
    entries = DiaEntry.undraft_entries(:page => {:size => 2, :current => 2})
    entries.load_page
    assert_equal 2, entries.results.length
  end

  # 下書きでない日記記事キーワード検索のテスト
  def test_undraft_entries_keyword_search
    # インデックスの初期化
    DiaEntry.clear_index!
    DiaEntry.reindex!
    
    # 空の文字列および nil は全件探索
    assert_equal 7, DiaEntry.undraft_entries_keyword_search('').length
    assert_equal 7, DiaEntry.undraft_entries_keyword_search(nil).length
    
    # limit テスト
    assert_equal 2, DiaEntry.undraft_entries_keyword_search('テストタイトル', :limit => 2).length
    
    # page テスト
    entries = DiaEntry.undraft_entries_keyword_search('テストタイトル', :page => {:size => 2, :current => nil})
    entries.load_page
    assert_equal 2, entries.results.length
    entries = DiaEntry.undraft_entries_keyword_search('テストタイトル', :page => {:size => 2, :current => 2})
    entries.load_page
    assert_equal 2, entries.results.length
  end
  
  # 画像の関連付けの追加テスト
  def test_add_images
    # 対象の記事の取得
    entry = DiaEntry.find(4)
    
    # 追加
    entry.add_images([1, 2])
    
    # 関連付けの存在を確認
    assert_not_nil DiaEntriesAbmImage.find(:first, :conditions => ["dia_entry_id = ? and abm_image_id = ?", 4, 1])
    assert_not_nil DiaEntriesAbmImage.find(:first, :conditions => ["dia_entry_id = ? and abm_image_id = ?", 4, 2])
  end

  define_method('test: 画像の関連付けをする（例外がかえされる可能性あり）') do 
    entry = DiaEntry.find(4)
    entry.add_images!([1, 2])
  
    assert_not_nil DiaEntriesAbmImage.find(:first, :conditions => ["dia_entry_id = ? and abm_image_id = ?", 4, 1])
    assert_not_nil DiaEntriesAbmImage.find(:first, :conditions => ["dia_entry_id = ? and abm_image_id = ?", 4, 2])
  end
  
  define_method('test: 画像の関連付けをするが失敗して例外がかえされる') do 
    entry = DiaEntry.find(4)
    
    assert_raise(ActiveRecord::RecordInvalid) do
      entry.add_images!([1, "abc"])
    end
  end
  
  # 画像の関連付けの更新テスト
  def test_update_images
    # 対象の記事の取得(画像1,2がすでに紐づいている)
    entry = DiaEntry.find(3)
    
    # 更新
    entry.update_images([2, 3])
    
    # 関連付けの確認
    assert_nil DiaEntriesAbmImage.find(:first, :conditions => ["dia_entry_id = ? and abm_image_id = ?", 3, 1]) # 消えているか確認
    assert_not_nil DiaEntriesAbmImage.find(:first, :conditions => ["dia_entry_id = ? and abm_image_id = ?", 3, 2]) # 存在するか確認
    assert_not_nil DiaEntriesAbmImage.find(:first, :conditions => ["dia_entry_id = ? and abm_image_id = ?", 3, 3]) # 存在するか確認
  end
  
  # 関連付けられた画像のIDの取得テスト
  def test_image_ids
    entry = DiaEntry.find(3)
    image_ids = entry.image_ids
    assert_equal 1, image_ids[0]
    assert_equal 2, image_ids[1]
  end
  
  # 自分の日記記事かの確認テスト
  def test_mine?
    # 対象ユーザーの取得
    current_base_user = BaseUser.find(1)
    
    # 自分の記事の場合
    dia_entry = DiaEntry.find(1)
    assert dia_entry.mine?(current_base_user)

    # 自分の記事じゃない場合
    dia_entry = DiaEntry.find(2)
    assert !dia_entry.mine?(current_base_user)
  end
  
  define_method('test: friend_accesible は友だちが閲覧できる記事を取得する') do 
    current_base_user = BaseUser.find(1)

    # 友だちのユーザーID
    friend_user_ids = current_base_user.base_friends.collect{|friend| friend.friend_id}
    
    dia_entry = DiaEntry.new({:dia_diary_id => DiaDiary.find_by_base_user_id(friend_user_ids[0]).id, 
                              :title => "test", :body => "test",
                              :public_level => UserRelationSystem::PUBLIC_LEVEL_ME})
    dia_entry.save! # ある友達の記事を自分にだけ公開にする
    
    entries = DiaDiary.find(1).dia_entries.friend_accesible
    assert_not_nil entries
    
    entries.each do |entry|
      # ともだちが自分にだけ公開している記事は表示しない
      assert_not_equal(entry.public_level, UserRelationSystem::PUBLIC_LEVEL_ME)
    end
  end
  
end