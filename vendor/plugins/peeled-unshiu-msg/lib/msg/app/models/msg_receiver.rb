# == Schema Information
#
# Table name: msg_receivers
#
#  id             :integer(4)      not null, primary key
#  msg_message_id :integer(4)      not null
#  base_user_id   :integer(4)      not null
#  trash_status   :integer(2)
#  replied_flag   :boolean(1)      not null
#  read_flag      :boolean(1)      not null
#  draft_flag     :boolean(1)
#  created_at     :datetime
#  updated_at     :datetime
#  deleted_at     :datetime
#

module MsgReceiverModule
  
  class << self
    def included(base)
      base.extend(ClassMethods)
      base.class_eval do
        acts_as_paranoid

        belongs_to :base_user
        belongs_to :msg_message
      end
    end
  end
  
  # read_flag の文字列表現を取得する
  def unread
    if self.read_flag
      return ''
    else
      return '(未読)'
    end
  end
  
  # replied_flag の文字列表現を取得する
  def replied
    if self.replied_flag
      return '(返信済み)'
    else
      return ''
    end
  end
  
  # ゴミ箱に入れる（受信者側） 
  def into_trash_box
    self.trash_status = MsgMessage::TRASH_STATUS_GARBAGE
    self.save
  end
  
  # ゴミ箱から受信箱に戻す
  def restore
    self.trash_status = MsgMessage::TRASH_STATUS_NONE
    self.save
  end

  # ゴミ箱から削除する（受信者側）
  def delete_completely
    self.trash_status = MsgMessage::TRASH_STATUS_BURN
    self.save
  end
  
  # 既読状態にする
  def read
    self.read_flag = true
    self.save
  end
  
  # メッセージを受信したことをメールで通知する
  def notify_receiving_message
    message = self.msg_message
    receiver = self.base_user
    sender = message.msg_sender.base_user
    
    BaseMailerNotifier.deliver_notify_receiving_message(message, sender, receiver)
  end
  
  module ClassMethods
    
    # 複数のメッセージをまとめてゴミ箱に入れる（受信者側）
    # 注意：受信箱のメッセージ以外が message_ids で指定されることを想定していないため、
    #     間違ってゴミ箱から削除されたメッセージのIDとかがしていされてもゴミ箱に入ります
    # TODO メソッド名変更。delete やめる
    def delete_messages(base_user_id, message_ids)
      update_all("trash_status = #{MsgMessage::TRASH_STATUS_GARBAGE}", ["base_user_id = ? and msg_message_id in (?)", base_user_id, message_ids])
    end
  
  end
end
