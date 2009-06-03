module MsgHelperModule
  
  def sender_name(message, link = false)
    msg_sender = message.msg_sender
    return '不明' unless msg_sender
    
    base_user = msg_sender.base_user
    if link || base_user.nil?
      link_to_user base_user
    else
      base_user.show_name
    end
  end

  def receiver_name(message, link = false)
    msg_receiver = message.msg_receivers[0]
    return '不明' unless msg_receiver
    
    base_user = msg_receiver.base_user
    if link || base_user.nil?
      link_to_user base_user
    else
      base_user.show_name
    end
  end
  
  # メッセージが自分が送信したものか、受信したがまだ読んでいなければread,
  # 受信して、既読なら new という css用のclass名を出力する
  def readcheck_class(message)
    if message.msg_sender.base_user_id == current_base_user.id || message.msg_receiver(current_base_user.id).read_flag
     'read'
    else
     'new'
    end
  end
  
  # 指定menuのページであったらsubmenuのclassにcurrentを出力する
  def current_submenu_class(current_menu, menu)
    'current' if current_menu == menu
  end
  
end
