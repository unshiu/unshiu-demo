# == Schema Information
#
# Table name: dia_entries
#
#  id                :integer(4)      not null, primary key
#  dia_diary_id      :integer(4)      not null
#  title             :string(255)     default(""), not null
#  body              :text
#  public_level      :integer(4)
#  draft_flag        :boolean(1)      not null
#  created_at        :datetime
#  updated_at        :datetime
#  deleted_at        :datetime
#  last_commented_at :datetime
#  contributed_at    :datetime
#

module DiaEntryModule
  
  class << self
    def included(base)
      base.extend(ClassMethods)
      base.class_eval do
        acts_as_paranoid
        acts_as_unshiu_user_relation
        acts_as_cached
        
        acts_as_searchable :searchable_fields => [:title, :body],
                           :attributes => {:draft_flag => :draft_flag, :public_level => :public_level, :contributed_at => :contributed_at}

        # 日記記事が属する日記
        belongs_to :dia_diary

        # 日記記事についたコメント
        has_many :dia_entry_comments, :dependent => :destroy

        # 日記記事とアルバム画像の紐づけ
        has_many :dia_entries_abm_images, :dependent => :destroy

        # 日記記事と紐づいたアルバム画像
        has_many :abm_images, :through => :dia_entries_abm_images,
        				 :conditions => 'dia_entries_abm_images.deleted_at is null',
        				 :order => 'abm_images.id'

        validates_length_of :title, :maximum => AppResources['base']['title_max_length'], :allow_nil => true
        validates_length_of :body, :maximum => AppResources['base']['body_max_length'], :allow_nil => true
        validates_presence_of :title, :body
        validates_good_word_of :title, :body
        
        validates_numericality_of :dia_diary_id, :public_level
        
        before_destroy :expire_portal_cache
        
        # 日記の持ち主がアクセス可能な記事
        named_scope :owner_accesible, :order => ['dia_entries.updated_at desc']
        
        # 友だちがアクセス可能な記事
        named_scope :friend_accesible, :conditions => ["public_level != ?", [UserRelationSystem::PUBLIC_LEVEL_ME]], 
                                       :order => ['dia_entries.updated_at desc']
                                     
        # 友だちの友だちにがアクセス可能な記事
        named_scope :foaf_accesible, :conditions => ["public_level not in (?)", [UserRelationSystem::PUBLIC_LEVEL_ME, UserRelationSystem::PUBLIC_LEVEL_FRIEND]], 
                                     :order => ['dia_entries.updated_at desc'] 
        
        # 友達ではないユーザがアクセス可能な記事
        named_scope :uncontacts_user_accesible, :conditions => ["public_level not in (?)", [UserRelationSystem::PUBLIC_LEVEL_ME, UserRelationSystem::PUBLIC_LEVEL_FRIEND, UserRelationSystem::PUBLIC_LEVEL_FOAF]], 
                                                :order => ['dia_entries.updated_at desc']
                                                
        # 非ユーザがアクセス可能な記事
        named_scope :unuser_accesible, :conditions => ["public_level = ?", UserRelationSystem::PUBLIC_LEVEL_ALL], 
                                       :order => ['dia_entries.updated_at desc'] 
                                                                                                                                    
      end
    end
  end
  
  module ClassMethods
    
    # クエリキャッシュの生存時間
    def ttl
      AppResources[:dia][:dia_diary_cache_time]
    end
    
    # メール投稿受信
    # _param1_:: mail 
    # _param2_:: base_mail_dispatch_info
    def receive(mail, base_mail_dispatch_info)
      
      if mail.has_attachments? # 画像以外が添付されているならエラーメールを送って終了
        for attachment in mail.attachments
          unless BaseMailerNotifier.image?(attachment)
            BaseMailerNotifier::deliver_failure_saving_dia_entry(mail, '画像でない添付ファイルが含まれています。')
            return
          end
        end
      end
      
      entry = nil
      DiaDiary.transaction { entry = receive_core(mail, base_mail_dispatch_info) }
      
      BaseMailerNotifier::deliver_success_saving_dia_entry(mail, entry.id)
    rescue => ex
      logger.info ex.to_s 
      BaseMailerNotifier::deliver_failure_saving_dia_entry(mail)
    end
    
    # base_user の友だちの日記一覧を取得する。ただし自分にのみ公開されている記事は表示しない
    # _param1_:: base_user 
    # _param2_:: options
    def friend_entries(base_user, options = {})
      return nil unless base_user
      
      friend_ids = base_user.friends.collect{|u| u.id}
      options.merge!({:include => :dia_diary, 
        :conditions => ["draft_flag = false and dia_diaries.base_user_id in (?) and public_level != ?", friend_ids, UserRelationSystem::PUBLIC_LEVEL_ME],
        :order => "contributed_at desc"})
      find(:all, options)
    end
    
    # 「全体に公開」の日記記事
    def public_entries(options = {})
      options.merge!({:conditions => ["draft_flag != true and public_level = ?", UserRelationSystem::PUBLIC_LEVEL_ALL], :order => 'contributed_at desc'})
      find(:all, options)
    end
    
    # ポータル用に全体へ公開な日記記事一覧を返す
    # 内容はキャッシュされており、一定期間経つか、該当日記の一つが削除されるまで同じものがかえされる
    # return:: 日記記事一覧
    def cache_portal_public_entries
      DiaEntry.get_cache("DiaEntry#portal_public_entries") do
        find(:all, :conditions => ["draft_flag != true and public_level = ?", UserRelationSystem::PUBLIC_LEVEL_ALL], 
                   :limit => AppResources[:dia][:portal_public_entry_list_size], :order => 'contributed_at desc' )
      end
    end
    
    # 「全体に公開」の日記記事をキーワード検索
    def public_entries_keyword_search(keyword, options = {})
      unless keyword
        keyword = ''
      end
      
      options.merge!({:attributes => ['draft_flag STRNE true', 'public_level NUMEQ 1'], :order => 'contributed_at NUMD', :find => {:order => 'contributed_at desc'}})
      fulltext_search(keyword, options)
    end
    
    # 「下書きでない」日記記事
    def undraft_entries(options = {})
      options.merge!({:conditions => 'draft_flag != true', :order => 'contributed_at desc'})
      find(:all, options)
    end
    
    # 「下書きでない」日記記事をキーワード検索
    def undraft_entries_keyword_search(keyword, options = {})
      unless keyword
        keyword = ''
      end
      
      options.merge!({:attributes => 'draft_flag STRNE true', :order => 'contributed_at NUMD', :find => {:order => 'contributed_at desc'}})
      fulltext_search(keyword, options)
    end
    
  private

    # 日記を受信したときのメインの処理
    # _param1_:: mail
    # _param2_:: base_mail_dispatch_info
    # return:: DiaEntry エントリ
    def receive_core(mail, base_mail_dispatch_info)
      diary = DiaDiary.find(base_mail_dispatch_info.model_id)
          
      # 日記記事作成（保存はまだしない）
      entry = DiaEntry.new
      entry.title = NKF.nkf('-w', mail.subject) # 明示的に UTF8 に変換
      entry.body = mail.plain_body
      entry.dia_diary_id = diary.id
      entry.public_level = diary.default_public_level
      entry.draft_flag = false
      entry.contributed_at = Time.now
      entry.save!
        
      if mail.has_attachments?
        # 添付画像を処理:自分専用のアルバムの中で一番最後に作ったやつをとってくる
        album = AbmAlbum.find_by_base_user_id_and_public_level(base_mail_dispatch_info.base_user_id, UserRelationSystem::PUBLIC_LEVEL_ME, :order => 'id desc')
        
        unless album
          album = AbmAlbum.new
          album.base_user_id = base_mail_dispatch_info.base_user_id
          album.title = I18n.t('view.noun.user_album_title')
          album.body = I18n.t('view.noun.user_album_body')
          album.public_level = UserRelationSystem::PUBLIC_LEVEL_ME
          album.save!
        end
        
        mail.attachments.each do |attachment|
          image = AbmImage.new
          image.abm_album_id = album.id
          image.title = File.basename(attachment.original_filename, ".*")
          image.body = nil
          image.image = attachment
          image.image_size = attachment.size
          image.original_filename = attachment.original_filename
          image.content_type = attachment.content_type
          image.save!
          
          # 画像を日記と紐づける
          deai = DiaEntriesAbmImage.new
          deai.abm_image_id = image.id
          deai.dia_entry_id = entry.id
          deai.save!
        end
      end
      
      return entry
    end
    
  end

  # 画像（と日記の関連付け）を追加
  # 重複とか考えていない強制追加なので新規作成用
  def add_images(image_ids)
    for image_id in image_ids
      deai = DiaEntriesAbmImage.new
      deai.abm_image_id = image_id
      deai.dia_entry_id = self.id
      deai.save
    end
  end
  
  # 画像（と日記の関連付け）を追加
  # 保存に失敗したら例外を返す
  # _param1_:: image_ids[]
  def add_images!(image_ids)
    for image_id in image_ids
      deai = DiaEntriesAbmImage.new({:abm_image_id => image_id, :dia_entry_id => self.id})
      deai.save!
    end
  end
  
  # 画像（と日記の関連付け）を追加
  # いらないのは消してもともとあるのは作らない
  # 更新用
  def update_images(new_image_ids)
    new_image_ids.collect!{|id| id.to_i}
    old_image_ids = image_ids
    deplication = new_image_ids & old_image_ids
    
    # いらないものを消す
    # 配列の引き算がしたい old_image_ids - deplication
    delete_image_ids = []
    for image_id in old_image_ids
      next if deplication.include?(image_id)      
      delete_image_ids << image_id
    end
    DiaEntriesAbmImage.destroy_all(["dia_entry_id = ? and abm_image_id in (?)", self.id, delete_image_ids])
    
    # 足りないものを足す
    # 配列の引き算がしたい new_image_ids - deplication
    for image_id in new_image_ids
      next if deplication.include?(image_id)
      deai = DiaEntriesAbmImage.new
      deai.abm_image_id = image_id
      deai.dia_entry_id = self.id
      deai.save
    end
  end
  
  def image_ids
    self.dia_entries_abm_images.collect{|deai| deai.abm_image_id}
  end
  
  def mine?(base_user)
    self.dia_diary.mine?(base_user)
  end

private

  def expire_portal_cache
    DiaEntry.cache_portal_public_entries.each do | dia_entry|
      if dia_entry.id == self.id
        self.class.expire_cache("DiaEntry#portal_public_entries")
        return # expire は一度だけ
      end
    end
  end
end
