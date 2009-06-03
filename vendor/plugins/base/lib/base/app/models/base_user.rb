# == Schema Information
#
# Table name: base_users
#
#  id                         :integer(4)      not null, primary key
#  login                      :string(255)
#  email                      :string(255)
#  crypted_password           :string(40)
#  salt                       :string(40)
#  created_at                 :datetime
#  updated_at                 :datetime
#  remember_token             :string(255)
#  remember_token_expires_at  :datetime
#  deleted_at                 :datetime
#  status                     :integer(4)
#  activation_code            :string(255)
#  crypted_uid                :string(255)
#  joined_at                  :datetime
#  quitted_at                 :datetime
#  new_email                  :string(255)
#  receive_system_mail_flag   :boolean(1)
#  receive_mail_magazine_flag :boolean(1)
#  message_accept_level       :integer(4)      default(2), not null
#  footmark_flag              :boolean(1)      default(TRUE), not null
#  base_carrier_id            :integer(4)
#  device_name                :string(255)
#  name                       :string(255)
#

require "digest"
require 'digest/sha1'
module BaseUserModule
  class << self
    def included(base)
      base.extend(ClassMethods)
      base.class_eval do
        include BaseUserSearch
        
        acts_as_paranoid
        
        has_many :base_friends, :dependent => :destroy
        has_many :friends, :through => :base_friends,
                           :conditions => ["base_friends.status = ? and base_friends.deleted_at is null", BaseFriend::STATUS_FRIEND],
                           :order => "base_users.created_at desc"
        has_many :friend_applies, # 英語的には applications が正しいのですが、逆にわかりづらそうなので
                           :class_name => "BaseFriend", :foreign_key => "friend_id",
                           :conditions => ["status = ? and base_friends.deleted_at is null", BaseFriend::STATUS_APPLYING],
                           :order => "created_at asc"
        
        has_many :base_favorites, :dependent => :destroy
        has_many :favorites, :through => :base_favorites, 
                             :conditions => "base_favorites.deleted_at is null",
                             :order => "base_users.created_at desc"
        
        has_one :base_profile, :dependent => :destroy
        
        has_many :base_user_roles, :dependent => :destroy
        
        belongs_to :base_carrier
        has_many :base_menus, :order => "base_menus.num"
        
        # Dia
        has_many :dia_diaries, :dependent => :destroy
        has_many :dia_entries, :through => :dia_diaries, :source => :dia_entries, :conditions => "draft_flag = false", :order => 'contributed_at desc'
        has_many :dia_entry_comments # 自分がつけたコメント。自分の記事につけたのを含む
        has_many :dia_commented_entries, # 自分がコメントをつけた日記記事。自分の記事を含む
        :through => :dia_entry_comments, :source => :dia_entry,
        :conditions => 'dia_entries.draft_flag != true',
        :group => 'dia_entries.id', :order => 'dia_entries.last_commented_at desc'
        
        # Msg
        has_many :msg_senders
        has_many :msg_send_messages, :through => :msg_senders, :source => :msg_message,
        :conditions => "(draft_flag = false or draft_flag is null) and trash_status is null"
        has_many :msg_draft_messages, :through => :msg_senders, :source => :msg_message,
        :conditions => "draft_flag = true and trash_status is null"
        has_many :msg_receivers
        has_many :msg_receive_messages, :through => :msg_receivers, :source => :msg_message,
        :conditions => "(draft_flag = false or draft_flag is null) and trash_status is null"
        has_many :msg_unread_messages, :through => :msg_receivers, :source => :msg_message,
        :conditions => "(draft_flag = false or draft_flag is null) and trash_status is null and read_flag != true"
        
        # Cmm
        if Unshiu::Plugins.active_cmm?
          has_many :cmm_communities_base_users, :dependent => :destroy
          has_many :cmm_communities, :through => :cmm_communities_base_users,
          :conditions => ["status in (?) and cmm_communities_base_users.deleted_at is null", CmmCommunitiesBaseUser::STATUSES_JOIN]
        end
        
        # Abm
        has_many :abm_albums, :dependent => :destroy
        has_many :abm_image_comments
        
        # Prf
        has_one :prf_profile, :dependent => :destroy
        
        # Pnt
        has_many :pnt_points, :dependent => :destroy
        
        # Virtual attribute for the unencrypted column
        attr_accessor :password, :uid
        
        validates_presence_of     :email
        validates_presence_of     :password,                   :if => :password_required?
        validates_length_of       :password, :within => 3..30, :if => :password_required?
        validates_confirmation_of :password,                   :if => :password_required?
        validates_format_of       :password, :with => /^[0-9a-zA-Z]+$/i, :if => :password_required?
        validates_length_of       :login,    :within => 3..30,  :if => :login_required?
        validates_length_of       :email,    :within => 3..AppResources[:base][:email_max_length]
        validates_uniqueness_of   :login, :case_sensitive => false, :scope => :deleted_at, :allow_blank => true
        validates_uniqueness_of   :email, :case_sensitive => false, :scope => :deleted_at
        validates_format_of       :email,
                                  :with       => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
        before_save :encrypt_password, :encrypt_uid
        
        # -------------------------------------
        # constants
        # -------------------------------------
        # status
        const_set('STATUS_TEMPORARY', 1) # 仮登録ユーザー
        const_set('STATUS_ACTIVE', 2) # 有効なユーザー
        const_set('STATUS_FORBIDDEN', 3) # ログイン禁止ユーザー
        const_set('STATUS_WITHDRAWAL', 4) # 自分で退会したユーザ
        const_set('STATUS_FORCED_WITHDRAWAL', 5) # 管理者により退会されたユーザ
        
        const_set('STATUS_NAMES', {base::STATUS_TEMPORARY => '仮登録', base::STATUS_ACTIVE => '有効', base::STATUS_FORBIDDEN => 'ログイン禁止',
          base::STATUS_WITHDRAWAL => '退会', base::STATUS_FORCED_WITHDRAWAL => '強制退会'})
        
        # ニックネームの質問ID
        # どこに書いておくか迷う。。。
        const_set('PRF_QUESTION_ID_NICKNAME', 5)
        
        named_scope :active, :conditions => ['status = ?', BaseUser::STATUS_ACTIVE], :order => ['created_at desc'] 
      end
    end
  end

  # name を base_profile と同期させる
  def after_save
    if base_profile && base_profile.name != self.name
      base_profile.update_attribute(:name, self.name)
    end
  end
  
  # 表示名
  # 実体は別に持ってアプリごとに違ったりするので alias
  def show_name
    name ? ERB::Util.html_escape(name + 'さん') : 'ニックネームなし'
  end

  # このユーザーが有効なら true，無効（ログイン不可）なら false を返す
  def active?
    self.status == BaseUser::STATUS_ACTIVE
  end
  
  # このユーザーがログイン禁止なら true，それ以外なら false を返す
  def forbidden?
    self.status == BaseUser::STATUS_FORBIDDEN
  end
  
  # 退会済みかを返す
  # return:: 退会済みであればtrue,そうでなければfalse
  def withdrawal?
    !self.deleted_at.nil?
  end
  
  # アクティベーションコードを生成する
  def make_activation_code
    self.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
  end
  
  # 仮登録ユーザーを本登録ユーザーに変更（有効化）
  # および、ユーザーの初期セットアップ
  def activate(password, receive_mail_magazine_flag)
    self.status = BaseUser::STATUS_ACTIVE
    self.joined_at = Time.now # 入会時間の記録
    self.password = password
    self.receive_mail_magazine_flag = receive_mail_magazine_flag
    self.receive_system_mail_flag = true
    self.make_activation_code # アクティベーションコードの設定し直し。多重登録を防ぐため
    self.save
  end
  
  # 友だち（サービスに加入していない人）をサービスに招待
  # 招待された人は仮登録ユーザーになり、そのユーザーを返す
  # メールアドレスが登録済みユーザー(アクティブ,アクセス禁止)または強制退会ユーザーだった場合は nil を返す
  # _return_:: 仮登録されたユーザー or nil
  def invite_friend(mail_address, invite_message)
    user = BaseUser.find_by_email(mail_address)
    if user.nil?
      banned_user = BaseUser.find_with_deleted(:first, :conditions => ['email = ? and status = ?', mail_address, BaseUser::STATUS_FORCED_WITHDRAWAL])
      return nil if banned_user
      user = BaseUser.temporary_registration_core(mail_address)
      send_invitation(user, invite_message)
      user
    elsif user.active? || user.forbidden?
      return nil
    else
      send_invitation(user, invite_message)
      user
    end
  end

  # 仮登録ユーザーに招待状を送る
  def send_invitation(temporary_user, invite_message)
    BaseMailerNotifier.deliver_invite_to_service(self, temporary_user, invite_message, :force)
  end

  # base_user_idのbaseUserが自分なら true
  def me?(base_user_id)
    self.id == base_user_id.to_i
  end
  
  # base_user_idのbaseUserが友だちなら true
  def friend?(base_user_id)
    BaseFriend.count(
      :conditions => ["friend_id = ? and base_user_id = ? and status = ?",
                      base_user_id, self.id, BaseFriend::STATUS_FRIEND]
    ) > 0
  end
  
  # 友だちの友だちのリスト
  # return は、BaseFriend のリスト
  def foafs
    BaseFriend.find_by_sql(["select base_friends.* from base_friends " +
      " LEFT OUTER JOIN base_friends base_user_base_friends on base_friends.base_user_id = base_user_base_friends.friend_id" +
      " where base_friends.status = ? and base_user_base_friends.status = ? and base_user_base_friends.base_user_id = ? and base_friends.friend_id != ?",
      BaseFriend::STATUS_FRIEND, BaseFriend::STATUS_FRIEND, self.id, self.id])
  end

  # base_user_idのbaseUserが友だちの友だちなら true
  def foaf?(base_user_id)
    BaseFriend.count_by_sql(["select * from base_friends " +
                            " LEFT OUTER JOIN base_friends  base_user_base_friends on base_friends.base_user_id = base_user_base_friends.friend_id" +
                            " where base_friends.friend_id = ? and base_friends.status = ? and base_user_base_friends.status = ? and base_user_base_friends.base_user_id = ? and base_friends.friend_id != ?",
                            base_user_id, BaseFriend::STATUS_FRIEND, BaseFriend::STATUS_FRIEND, self.id, self.id]) > 0
  end
  
  # あしあとをつけるかを判断する
  # _return_:: 足跡をつける場合はtrue,そうでなければfalse
  def footmark?
    self.footmark_flag
  end

  # システムからのメール送信を許可しているかを判断する
  # _return_:: 許可している場合はtrue,そうでなければfalse
  def receive_system_mail?
    self.receive_system_mail_flag
  end

  # メールマガジンのメール送信を許可しているかを判断する
  # _return_:: 許可している場合はtrue,そうでなければfalse
  def receive_mail_magazine?
    self.receive_mail_magazine_flag
  end
  
  def latest_login
    login = BaseLatestLogin.find_by_base_user_id(self.id)
    login.nil? ? nil : login.latest_login
  end
  
  module ClassMethods
    # ユーザーが有効なら true，無効（ログイン不可）なら false を返す
    # ユーザーが存在しない場合は false を返す
    # _base_user_id_:: 有効か否かを調べる対象のユーザーId
    def active?(base_user_id)
      begin
        base_user = find(base_user_id)
        base_user.active?
      rescue ActiveRecord::RecordNotFound
        false
      end
    end
    
    # アクティブな全ユーザー
    def active_users
      find(:all, :conditions => "status = #{BaseUser::STATUS_ACTIVE}")
    end
    
    # メールアドレスから仮登録ユーザを作成する。
    # ただし登録済みの場合は新規作成しない。また強制解約されたユーザのメールアドレスの場合はnilがかえる
    # _param1_:: email 
    # _return_:: base_user
    def create_temporary_user_from_email(email)
      user = find_by_email(email)
      if user.nil?
        banned_user = BaseUser.find_with_deleted(:first, :conditions => ['email = ? and status = ?', email, BaseUser::STATUS_FORCED_WITHDRAWAL])
        user = temporary_registration_core(email) unless banned_user
      end
      user
    end
    
    # ユーザを仮登録して承認コードを作成する
    # _param1_:: email 
    # _return_:: base_user
    def temporary_registration_core(mail_address)
      user = BaseUser.new({ :email => mail_address, :status => BaseUser::STATUS_TEMPORARY })
      user.make_activation_code
      user.save!
      user
    end
    
    # プロフィル情報から検索
    # 検索条件
    #  +ユーザ情報があてはまること
    #  +プロフィール情報があてはまること  
    #  +ポイントが指定範囲内なこと
    # デフォルトでは、有効なユーザー(STATUS_ACTIVE)のみを検索している。
    # 変更したい場合は、user_info[:status] を指定しておく。
    # _param1_:: user_info     ユーザ情報のハッシュ。　　　　key = カラム名, value = 検索値
    # _param2_:: profile_info  プロフィール情報のハッシュ。　key = カラム名, value = 検索値
    # _param3_:: point_info    ポイント情報のハッシュ。　  key = カラム名, value = 検索値
    # _return_:: 対象ユーザ
    def find_users_by_all_search_info(user_info = {}, profile_info = {}, point_info = {}, options = {}, count = nil)
      # 対象ユーザーの絞りを status で行い、意味的に重複する deleted_at を条件から外す
      unless user_info[:status]
        user_info[:status] = [BaseUser::STATUS_ACTIVE] # 登録済みユーザーのみ
      end
      options[:with_deleted] = true
      
      # joins 使うから select をちゃんと指定
      options[:select] = 'DISTINCT base_users.id, base_users.*'
      
      # joins
      joins = ""
      joins << " LEFT OUTER JOIN pnt_points ON pnt_points.base_user_id = base_users.id" unless point_info.blank?
      joins << " LEFT OUTER JOIN base_profiles ON base_users.id = base_profiles.base_user_id" unless profile_info.blank?
      options[:joins] = joins
      
      # conditions
      condition_sql = BaseUserSearch.create_condition_sql(user_info, profile_info, point_info)
      options[:conditions] = sanitize_sql(condition_sql) unless condition_sql.blank?
      
      # find
      if count
        options.delete(:with_deleted)
        options[:select] = 'DISTINCT base_users.id'
        count_with_deleted(options)
      else
        find(:all, options)
      end
    end
    
    # 全ユーザ数(仮登録者を除き退会者は含める)をかえす
    # _return_:: 全ユーザ数
    def count_all_users
      count_with_deleted(:conditions => [" status != ? ", BaseUser::STATUS_TEMPORARY])
    end
    
    # 退会者数を返す
    # _return_:: 退会者数
    def count_by_withdrawal
      count_with_deleted(:conditions => [" status in ( ? ) ", [BaseUser::STATUS_WITHDRAWAL, BaseUser::STATUS_FORCED_WITHDRAWAL]])
    end
    
    # DM受信者数を返す
    # _return_:: DM受信者数
    def count_by_receive_mail_magazine
      count(:conditions => "receive_mail_magazine_flag = true")
    end
    
    # DM拒否数を返す
    # _return_:: DM拒否数
    def count_by_reject_mail_magazine
      count(:conditions => "receive_mail_magazine_flag = false")
    end
    
    # 指定範囲内でユーザ登録したユーザ数を取得する
    # _param1_:: start_date　範囲開始日
    # _param2_:: end_date 範囲終了日
    # _return_:: 指定範囲内でユーザ登録したユーザ数
    def count_joined_at_by_period(start_date, end_date)
      count_with_deleted(:conditions => ['joined_at between ? and ?', start_date, end_date])
    end
    
    # 指定範囲内で退会したユーザ数を取得する
    # _param1_:: start_date　範囲開始日
    # _param2_:: end_date 範囲終了日
    # _return_:: 指定範囲内で退会したユーザ数
    def count_quitted_at_by_period(start_date, end_date)
      count_with_deleted(:conditions => ['quitted_at between ? and ?', start_date, end_date])
    end
    
    # 指定日付で有効だったユーザ数を取得する
    # _param1_:: start_date　範囲開始日
    # _param2_:: end_date 範囲終了日
    # _return_:: 指定範囲内で有効だったユーザ数
    def count_active_at_by_date(date)
      limit = date + 1.days
      count_with_deleted(:conditions => ['joined_at < ? and ( quitted_at is null or quitted_at > ? ) ', limit, limit])
    end
    
    # かんたんログイン
    def authenticate_by_uid(uid)
      return nil if uid.blank?
      find_by_crypted_uid(self.encrypt_uid(uid))
    end
    
    def status_name(status)
      BaseUser::STATUS_NAMES[status]
    end
  
    # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
    def authenticate(login, password)
      u = find_by_login(login) # need to get the salt
      return nil unless u
      return nil if u.login != login
      u.authenticated?(password) ? u : nil
    end
    
    # Encrypts some data with the salt.
    def encrypt(password, salt)
      Digest::SHA1.hexdigest("--#{salt}--#{password}--")
    end
    
    def encrypt_uid(uid)
      encrypt(uid, Util.secret_key('uid_key'))
    end
  end
  
  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end
  
  def authenticated?(password)
    crypted_password == encrypt(password)
  end
  
  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    self.remember_token_expires_at = 2.weeks.from_now.utc
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end
  
private

  # before filter 
  def encrypt_password
    return if password.blank?
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if self.salt.blank?
    self.crypted_password = encrypt(password)
  end
  
  def encrypt_uid
    return if uid.blank?
    self.crypted_uid = self.class.encrypt_uid(uid)
  end
  
  def password_required?
    return false if status == BaseUser::STATUS_TEMPORARY
    crypted_password.blank? || !password.blank?
  end

  # ログインIDが必要かどうか。仮登録時以外は必要
  def login_required?
    status != BaseUser::STATUS_TEMPORARY
  end
  
end
