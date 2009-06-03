# == Schema Information
#
# Table name: msg_messages
#
#  id                :integer(4)      not null, primary key
#  title             :string(255)     default(""), not null
#  body              :text
#  created_at        :datetime
#  updated_at        :datetime
#  deleted_at        :datetime
#  parent_message_id :integer(4)
#

module MsgMessageModule
  
  class << self
    def included(base)
      base.extend(ClassMethods)
      base.class_eval do
        acts_as_paranoid

        # 送信者
        has_one :msg_sender, :dependent => :destroy

        # 受信者
        has_many :msg_receivers, :dependent => :destroy
        has_many :msg_receiver_base_users, :include => [:base_user], :class_name => 'MsgReceiver'
        
        # 通報
        has_many :msg_notifies

        # 親（返信元）メッセージ
        belongs_to :parent_message, :class_name => 'MsgMessage', :foreign_key => 'parent_message_id'

        # 子（返信された）メッセージ
        has_many :child_messages, :class_name => 'MsgMessage', :foreign_key => 'parent_message_id'

        validates_length_of :title, :maximum => AppResources['base']['title_max_length']
        validates_length_of :body, :maximum => AppResources['base']['body_max_length']
        validates_presence_of :title, :body
        validates_good_word_of :title, :body

        # ゴミ箱に入っているかなどのステータス
        const_set('TRASH_STATUS_NONE',    nil) # 受信箱，送信箱，下書き箱のどこかに入っている状態
        const_set('TRASH_STATUS_GARBAGE',   1) # ゴミ箱に入っている状態
        const_set('TRASH_STATUS_BURN',      2) # ゴミ箱からも消された状態（送信者もしくは受信者が誰かがわかるようにレコード自体は削除せずに取っておく。論理削除とも区別）

        # メッセージ送信可能（あるユーザーに送っていい人）レベル
        # DB上は BaseUser に持つ
        const_set('MESSAGE_ACCEPT_LEVEL_NONE',   nil) # 全員不可。現在は未使用
        const_set('MESSAGE_ACCEPT_LEVEL_ALL',      1) # 非ログインユーザーを含む全員。便宜上用意しているだけで、基本未使用
        const_set('MESSAGE_ACCEPT_LEVEL_USER',     2) # ログインユーザー全員
        const_set('MESSAGE_ACCEPT_LEVEL_FOAF',     3) # 友だちの友だちまで
        const_set('MESSAGE_ACCEPT_LEVEL_FRIEND',   4) # 友だちのみ
        
        # 登録情報変更時に選択肢に現れる一覧
        const_set('MESSAGE_ACCEPT_LEVELS', {"サービス利用者全員" => MsgMessage::MESSAGE_ACCEPT_LEVEL_USER,
                                            "友だちのみ"     => MsgMessage::MESSAGE_ACCEPT_LEVEL_FRIEND,
                                            "友だちの友だちまで" => MsgMessage::MESSAGE_ACCEPT_LEVEL_FOAF}) 
        
        # value から文字表現を引く
        const_set('MESSAGE_ACCEPT_LEVELS_HASH', {})
        base::MESSAGE_ACCEPT_LEVELS.each { |item| key = item[1] ; value = item[0] ; base::MESSAGE_ACCEPT_LEVELS_HASH[key] = value }
        
        # ゴミ箱一覧：　並び順はnext_message, prev_message取得する際に影響するので個別に指定する
        named_scope :garbage, lambda { |base_user_id| 
          { :include => ["msg_sender", "msg_receivers"],
            :conditions => ["(msg_senders.base_user_id = :base_user_id and msg_senders.trash_status = :status) or (msg_receivers.base_user_id = :base_user_id and msg_receivers.trash_status = :status)", 
                           { :base_user_id => base_user_id, :status => MsgMessage::TRASH_STATUS_GARBAGE } ] }
        }
        
        named_scope :next_message, lambda { |id| 
          { :conditions => [' msg_messages.id > ? ', id], :order => ['msg_messages.id asc'], :limit => 1 } 
        }
        
        named_scope :prev_message, lambda { |id| 
          { :conditions => [' msg_messages.id < ? ', id], :order => ['msg_messages.id desc'], :limit => 1 } 
        }
      end
    end
  end
  
  # base_user がこのメッセージの送信者なら true、それ以外なら false を返す
  def sender?(base_user)
    if base_user && base_user != :false # means logged_in?
      sender = self.msg_sender.base_user
      return false unless sender
    
      sender.id == base_user.id
    else
      return false
    end
  end

  # base_user がこのメッセージの受信者なら true、それ以外なら false を返す
  def receiver?(base_user)
    if base_user && base_user != :false # means logged_in?
      my_receiver = self.msg_receiver(base_user.id)
      return false unless my_receiver
      receiver = my_receiver.base_user
      return false unless receiver
    
      receiver.id == base_user.id
    else
      return false
    end
  end
  
  # このメッセージと base_user_id に対応する MsgReceiver オブジェクトを取得する
  def msg_receiver(base_user_id)
    self.msg_receivers.find(:first, :conditions => ["base_user_id = ?", base_user_id])
  end
  
  # リプライ用にtitleを設定する。長過ぎる場合は自動でトリミングする
  # _param1_:: title
  def reply_title=(value)
    self.title = ("Re: " + value).split(//)[0..AppResources[:base][:title_max_length]-1].to_s
  end
  
  # リプライ用にbodyを設定する。長過ぎる場合は自動でトリミングする
  # _param1_:: body
  def reply_body=(value)
    self.body = value.gsub(/^/, "> ").split(//)[0..AppResources[:base][:body_max_length]-1].to_s
  end
  
  module ClassMethods
    
    # sender（アクセスユーザー）が receiver_id のユーザーにメッセージを送れるなら、true。送れないなら false
    def acceptable?(sender, receiver_id)
      if sender && sender != :false # means logged_in?
        # 受信者取得
        receiver = BaseUser.find(receiver_id)
      
        # 送信者，受信者の関係を取得
        relation = UserRelationSystem.user_relation(sender, receiver_id)
      
        # 自分自身にはメッセージは送れない
        if relation == UserRelationSystem::USER_RELATION_EQUAL
          return false
        end
      
        case receiver.message_accept_level
          when MsgMessage::MESSAGE_ACCEPT_LEVEL_USER
          return true
          when MsgMessage::MESSAGE_ACCEPT_LEVEL_FOAF
          return true if relation == UserRelationSystem::USER_RELATION_FOAF || relation == UserRelationSystem::USER_RELATION_FRIEND
          when MsgMessage::MESSAGE_ACCEPT_LEVEL_FRIEND
          return true if relation == UserRelationSystem::USER_RELATION_FRIEND
        end
      else
        # ログインしていなければ送信不可
        return false
      end
    end

    # base_user のゴミ箱メッセージ数を取得する
    def garbage_count(base_user_id)
      return count(:include => ['msg_sender', 'msg_receivers'],
                   :conditions => ["(msg_senders.base_user_id = ? and msg_senders.trash_status = 1) or (msg_receivers.base_user_id = ? and msg_receivers.trash_status = 1)", base_user_id, base_user_id])
    end
  
    # base_user のゴミ箱メッセージ一覧を paginate 付きで取得する
    # _param1_:: base_user_id
    # _param2_:: size
    # _param3_:: current_page
    def garbage_messages_with_paginate(base_user_id, size, current_page)
      garbage(base_user_id).find(:all, {:page => {:size => size, :current => current_page }, :order => ['msg_messages.id desc'] })    
    end
    
    # base_user のゴミ箱を空にする
    def clean_trash_box(base_user_id)
      MsgReceiver.update_all("trash_status = #{MsgMessage::TRASH_STATUS_BURN}",
        ["trash_status = #{MsgMessage::TRASH_STATUS_GARBAGE} and base_user_id = ?", base_user_id])
      MsgSender.update_all("trash_status = #{MsgMessage::TRASH_STATUS_BURN}",
        ["trash_status = #{MsgMessage::TRASH_STATUS_GARBAGE} and base_user_id = ?", base_user_id])
    end

    # 下書きじゃないメッセージ一覧の取得
    # FIXME 管理画面の一覧を取得しているメソッドらしくここでページサイズをしているが、メソッド名ではそれがわからないし、本来コントローラで指定されるべき
    def undraft_messages(page)
      find(:all, :include => "msg_sender",
           :conditions => "msg_senders.draft_flag = false",
           :page => {:size => AppResources["mng"]["standard_list_size"], :current => page},
           :order => 'msg_messages.updated_at desc')
    end
  
    # 管理者が送ったメッセージ一覧の取得
    # FIXME 管理画面の一覧を取得しているメソッドらしくここでページサイズをしているが、メソッド名ではそれがわからないし、本来コントローラで指定されるべき
    def manager_messages(page)
      find(:all, :joins => "LEFT OUTER JOIN msg_senders ON msg_messages.id = msg_senders.msg_message_id LEFT OUTER JOIN base_user_roles ON msg_senders.base_user_id = base_user_roles.base_user_id",
           :conditions => ["role = ?", 'manager'],
           :select => "msg_messages.*",
           :page => {:size => AppResources["mng"]["standard_list_size"], :current => page},
           :order => 'msg_messages.updated_at desc')    
    end
  
    # 通報されたメッセージ一覧の取得
    # FIXME 管理画面の一覧を取得しているメソッドらしくここでページサイズをしているが、メソッド名ではそれがわからないし、本来コントローラで指定されるべき
    def notified_messages(page)
      find(:all, :include => "msg_notifies",
           :conditions => 'msg_notifies.id is not null',
           :page => {:size => AppResources["mng"]["standard_list_size"], :current => page},
           :order => 'msg_notifies.id, msg_notifies.updated_at desc')
    end
  end
  
end
