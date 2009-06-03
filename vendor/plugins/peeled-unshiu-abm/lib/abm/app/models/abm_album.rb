# == Schema Information
#
# Table name: abm_albums
#
#  id                 :integer(4)      not null, primary key
#  base_user_id       :integer(4)      not null
#  title              :string(255)
#  body               :text
#  created_at         :datetime
#  updated_at         :datetime
#  deleted_at         :datetime
#  public_level       :integer(4)
#  cover_abm_image_id :integer(4)
#

require 'fileutils'

# アルバムを表現するクラス
#
module AbmAlbumModule
  
  class << self
    def included(base)
      base.extend(ClassMethods)
      
      base.class_eval do
        acts_as_paranoid
        acts_as_unshiu_user_relation
        acts_as_cached
        
        belongs_to :base_user
        has_many :abm_images, :dependent => :destroy
        belongs_to :cover_abm_image,  :class_name => 'AbmImage', :foreign_key => 'cover_abm_image_id'
        
        validates_length_of :title, :maximum => AppResources['base']['title_max_length']
        validates_length_of :body, :maximum => AppResources['base']['body_max_length']
        validates_presence_of :title, :body
        validates_good_word_of :title, :body
        validates_numericality_of :public_level
        
        before_destroy :expire_portal_cache
        
      end
      
    end
   
  end
  
  # アルバムがuser_idのユーザーのアルバムかどうかを判別する。
  def mine?(user_id)
    self.base_user_id == user_id
  end
  alias :is_mine? :mine?
  
  module ClassMethods
    
    # クエリキャッシュの生存時間
    def ttl
      AppResources[:abm][:abm_album_cache_time]
    end
    
    # 自分のアルバム一覧を取得する
    # _param1_:: base_user_id
    # _param2_:: size
    # _param3_:: current_page
    def find_my_albums_with_pagenate(base_user_id, size, current_page = 0)
      find(:all, :conditions => ['base_user_id = ?', base_user_id], :page => {:size => size, :page => current_page })
    end
    
    # base_userがアクセス可能なuser_idのユーザーのアルバムをoptionsを加えてすべて検索する。
    def find_accessible_albums(base_user, user_id, options = {})
      owner = BaseUser.find(user_id)
      if base_user && base_user != :false
        if base_user.me?(user_id)
          # 自分にはすべてのアルバムを表示する
          # nop
        elsif base_user.friend?(user_id)
          # 友だちには自分専用以外を表示する
          options[:conditions] = ["public_level != ?", UserRelationSystem::PUBLIC_LEVEL_ME]
        elsif base_user.foaf?(user_id)
          # 友だちの友だちには自分専用、友だち向けを表示しない
          options[:conditions] = ["public_level not in (?)", [UserRelationSystem::PUBLIC_LEVEL_ME, UserRelationSystem::PUBLIC_LEVEL_FRIEND]]
        else
          # ログインユーザーには、自分専用、友だちに公開、友だちの友だちまで公開を表示しない
          options[:conditions] = ["public_level not in (?)", [UserRelationSystem::PUBLIC_LEVEL_ME, UserRelationSystem::PUBLIC_LEVEL_FRIEND, UserRelationSystem::PUBLIC_LEVEL_FOAF]]
        end
      else
        # 非ログインユーザーには、全体に公開のみを表示する
        options[:conditions] = ["public_level = ?", UserRelationSystem::PUBLIC_LEVEL_ALL]
      end
      owner.abm_albums.find(:all, options)
    end
  
    # 友だちのアルバム一覧
    def friend_albums(base_user, options = {})
      friend_ids = base_user.friends.collect{|u| u.id}
      options.merge!({
        :conditions => ["base_user_id in (?) and public_level < #{UserRelationSystem::PUBLIC_LEVEL_ME}", friend_ids],
        :order => "updated_at desc"})
      find(:all, options)
    end
  
    # 「全体に公開」のアルバムをoptionsの条件で返す。
    def public_albums(options = {})
      options.merge!({:conditions => ["public_level = ?", UserRelationSystem::PUBLIC_LEVEL_ALL], :order => 'updated_at desc'})
      find(:all, options)
    end
  
    # ポータル用に全体へ公開なアルバム一覧を返す
    # 内容はキャッシュされており、一定期間経つか、該当アルバムの一つが削除されるまで同じものがかえされる
    # return:: 公開アルバム一覧
    def cache_portal_public_albums
      AbmAlbum.get_cache("AbmAlbum#portal_public_albums") do
        find(:all, :conditions => ["public_level = ?", UserRelationSystem::PUBLIC_LEVEL_ALL], 
                   :limit => AppResources[:abm][:portal_album_list_size], :order => 'updated_at desc' )
      end
    end
  
    # あるユーザの現在の総利用画像容量を取得する
    # _param1_:: base_user_id
    # return:: 現在の利用画像容量
    def sum_image_size_by_base_user_id(base_user_id)
      AbmImage.sum(:image_size, :include => [:abm_album], :conditions => [' abm_albums.base_user_id = ? ', base_user_id])
    end
    
    # メールの添付ファイルをアルバムに保存する
    # _param1_:: mail 
    # _param2_:: base_mail_dispatch_info
    def save_with_mail(mail, base_mail_dispatch_info)
      
      unless mail.has_attachments?
        BaseMailerNotifier::deliver_failure_saving_abm_images(mail, '画像を添付してください。')
        return 
      end
      
      for attachment in mail.attachments
        unless BaseMailerNotifier.image?(attachment) # 画像じゃない
          BaseMailerNotifier::deliver_failure_saving_abm_images(mail, '画像でない添付ファイルが含まれています。')
          return
        end
      end

      AbmImage.transaction { receive_core(mail, base_mail_dispatch_info) }
    
      BaseMailerNotifier::deliver_success_saving_abm_images(mail, base_mail_dispatch_info.model_id)
    
    rescue => ex
      logger.info ex.to_s
      BaseMailerNotifier::deliver_failure_saving_abm_images(mail)
    end
  
  private
  
    # 画像を受信したときのメインの処理
    # _param1_:: mail
    # _param2_:: base_mail_dispatch_info
    def receive_core(mail, base_mail_dispatch_info)
      album_id = base_mail_dispatch_info.model_id
      
      if mail.has_attachments?
        mail.attachments.each do |attachment|
          image = AbmImage.new
          image.abm_album_id = album_id
          image.title = mail.subject.blank? ? File.basename(attachment.original_filename, ".*") : NKF.nkf('-w', mail.subject)
          image.body = mail.plain_body.blank? ? nil : NKF.nkf('-w', mail.plain_body)
          image.image = attachment
          image.image_size = attachment.size
          image.original_filename = attachment.original_filename
          image.content_type = attachment.content_type
          image.save!
        end
      end
    end
      
  end
  
private

  def expire_portal_cache
    AbmAlbum.cache_portal_public_albums.each do | abm_album |
      if abm_album.id == self.id
        self.class.expire_cache("AbmAlbum#portal_public_albums")
        return # expire は一度だけ
      end
    end
  end
end
