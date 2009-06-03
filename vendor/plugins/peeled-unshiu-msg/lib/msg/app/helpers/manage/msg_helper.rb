module ManageMsgHelperModule
  
  def sender_name(message)
    msg_sender = message.msg_sender
    return '' unless msg_sender
    
    base_user = message.msg_sender.base_user
    unless base_user == nil
      base_user.show_name
    else
      "退会した#{I18n.t('view.noun.base_user')}"
    end
  end

  def receiver_names(message)
    return '' if message.msg_receivers.count == 0
    
    names = ''
    limit = 3
    for msg_receiver in message.msg_receivers.find(:all, :limit => limit)
      base_user = msg_receiver.base_user
      unless base_user == nil
        names << base_user.show_name + ', '
      else
        names << "退会した#{I18n.t('view.noun.base_user')}, "
      end
    end
    names = names[0..names.length - 3] # 最後のカンマをカット
    count = message.msg_receivers.count
    if count > limit
      names << "...(#{count}名)"
    end
    names
  end
end
