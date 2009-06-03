module BaseUserConfigHelperModule
  def message_accept_level_label(message_accept_level)
    MsgMessage::MESSAGE_ACCEPT_LEVELS_HASH[message_accept_level]
  end
end
