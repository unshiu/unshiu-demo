module MsgMessageControllerModule
  
  class << self
    def included(base)
      base.class_eval do
        before_filter :receiver_check, :only => ["new", "confirm", "create", "done"]
        before_filter :sender_only_and_exists_receiver, :only => ["edit", "update", "update_confirm"]
        before_filter :receiver_only_and_exists_sender, :only => ["reply", "reply_with_quotation"]
        before_filter :owner_only, :only => ["garbage_show", "__mobile_garbage_show"]
        before_filter :send_messages_only, :only => ["delete_draft_messages", "delete_draft_messages_confirm"]
        before_filter :sender_or_receiver_del_require, :only => ["delete_from_trash_box_confirm", "delete_from_trash_box"] 
        
        nested_layout_with_done_layout("msg_application")
      end
    end
  end
  
  def index
    @msg_messages = current_base_user.msg_receive_messages.find(:all, :order => ["id desc"],
                                                                :page=>{:size => AppResources["msg"]["message_list_size"], 
                                                                :current => params[:page]})
    setup_current_user_box_count
  end
  
  def __mobile_index
    setup_current_user_box_count
  end

  def draft_list
    @messages = current_base_user.msg_draft_messages.find(:all, :order => ["id desc"],
                                                          :page=>{:size => AppResources["msg"]["message_list_size"], 
                                                          :current => params[:page]})
    setup_current_user_box_count
  end
  
  def __mobile_draft_list
    @messages = current_base_user.msg_draft_messages.find(:all, :order => ["id desc"],
                                                          :page=>{:size => AppResources["msg"]["message_list_size_mobile"], 
                                                          :current => params[:page]})
  end

  def garbage_list
    @messages = MsgMessage.garbage_messages_with_paginate(current_base_user.id, AppResources[:msg][:message_list_size], params[:page])
    setup_current_user_box_count
  end
  
  def __mobile_garbage_list
    @messages = MsgMessage.garbage_messages_with_paginate(current_base_user.id, AppResources[:msg][:message_list_size_mobile], params[:page])
  end
  
  def new
    @message = MsgMessage.new
    @receivers = []
  
    if params[:receivers]
      params[:receivers].each do |receiver|
        @receivers << BaseUser.find(receiver)
      end
    end
    setup_current_user_box_count
    
  end
  
  # 宛先一覧を表示する
  def friend_list
    if params[:receivers].blank?
      @receivers = []
      @base_friends = current_base_user.friends.find(:all, :page => {:size => AppResources[:base][:friend_list_size], :current => params[:page]})
    else
      @receivers = params[:receivers]
      @base_friends = current_base_user.friends.find(:all, :conditions => [" base_friends.friend_id not in (?) ", @receivers], 
                                                           :page => {:size => AppResources[:base][:friend_list_size], :current => params[:page]})
    end
  end
  
  def receivers_remote
    receivers = current_base_user.friends
    result = []
    receivers.each do |receiver|
      image = ""
      if receiver.base_profile.nil? || receiver.base_profile.image.nil?
        image = '/images/default/icon/default_profile_image.gif'
      else 
        image = ApplicationController.helpers.url_for_image_column(receiver.base_profile, :image, :thumb)
      end
      result << { :id => receiver.id, :text => receiver.name, :image => image, :extra => nil }
    end
    
    render :json => result.to_json
  end

  def receiver
    @receiver = params[:receiver]
  end
  
  def confirm
    @message = MsgMessage.new(params[:message])
    @receivers = []
    params[:receivers].each do |receiver|
      @receivers << BaseUser.find(receiver)
    end
    
    unless @message.valid?
      render :action => 'new'
      return
    end
    
    if params[:draft] != nil
      MsgMessage.transaction do 
        @message.save!
      
        msg_sender = MsgSender.new
        msg_sender.base_user_id = current_base_user.id
        msg_sender.msg_message_id = @message.id
        msg_sender.draft_flag = true
        msg_sender.save!
    
        @receivers.each do |receiver|
          msg_receiver = MsgReceiver.new
          msg_receiver.base_user_id = receiver.id
          msg_receiver.msg_message_id = @message.id
          msg_receiver.draft_flag = true
          msg_receiver.save!
        end
      end
      
      redirect_to :action => 'draft_done', :id => @message.id
      return
    end
  end
  
  def create
    @message = MsgMessage.new(params[:message])
    @receivers = []
    unless params[:receivers].nil?
      params[:receivers].each do |receiver|
        @receivers << BaseUser.find(receiver)
      end
    end
    
    if cancel?
      setup_current_user_box_count
      render :action => 'new'
      return
    end
    
    if !@message.valid? || params[:receivers].nil?
      if params[:draft]
        flash[:notice] = t('view.flash.error.msg_message_draft_create')
      else 
        flash[:notice] = t('view.flash.error.msg_message_create')
      end
      setup_current_user_box_count
      @receivers = []
      unless params[:receivers].nil?
        params[:receivers].each do |receiver|
          @receivers << BaseUser.find(receiver)
        end 
      end
      
      render :action => 'new'
      return
    end
      
    msg_sender = MsgSender.new({:base_user_id => current_base_user.id})
    msg_sender.draft_flag = true if params[:draft]
    
    msg_receivers = []
    @message.save
      
    msg_sender.msg_message_id = @message.id 
    msg_sender.save
      
    @receivers.each do |receiver|
      msg_receiver = MsgReceiver.new({:base_user_id => receiver.id})
      msg_receiver.msg_message_id = @message.id
      msg_receiver.draft_flag = true if params[:draft]
      msg_receiver.save
      msg_receivers << msg_receiver
    end
      
    if @message.parent_message_id
      parent = MsgMessage.find(@message.parent_message_id)
      parent_receiver = parent.msg_receiver(current_base_user.id)
      parent_receiver.replied_flag = true
      parent_receiver.save
    end
    
    if params[:draft]
      flash[:notice] = t('view.flash.notice.msg_message_draft_create')
    else
      msg_receivers.each do |msg_receiver| # レコードの処理が完全に終わってから
        msg_receiver.notify_receiving_message
      end
      flash[:notice] = t('view.flash.notice.msg_message_create')
    end
  
    if request.mobile?
      redirect_to :action => 'done', :id => @message.id
    else
      redirect_to :action => 'index'
    end
  end
  
  def done
    @msg_message = MsgMessage.find(params[:id])
  end
  
  def edit
    @message = MsgMessage.find(params[:id])
    @receivers = []
    @message.msg_receiver_base_users.inject(@receivers) {|result, item| result << item.base_user}
    setup_current_user_box_count
  end

  def update_confirm
    old_message = MsgMessage.find(params[:id])
    @message = MsgMessage.new(params[:message])
    @receivers = []
    old_message.msg_receiver_base_users.inject(@receivers) {|result, item| result << item.base_user}
    
    unless @message.valid?
      render :action => 'edit'
      return
    end
    if params[:draft] != nil
      old_message.update_attributes(params[:message])
      
      redirect_to :action => 'draft_done'
      return
    end
  end
  
  # 下書きからの編集
  def update
    message = MsgMessage.find(params[:id])
    if cancel?
      @message = MsgMessage.new(params[:message])
      @receivers = message.msg_receivers
      render :action => 'edit'
      return
    end
    
    message.update_attributes(params[:message])
    
    if params[:draft]
      flash[:notice] = t('view.flash.notice.msg_message_draft_update')
    else
      flash[:notice] = t('view.flash.notice.msg_message_update')
      msg_sender = message.msg_sender
      msg_sender.draft_flag = false
      msg_sender.save

      msg_receiver = message.msg_receivers[0]
      msg_receiver.draft_flag = false
      msg_receiver.save
      msg_receiver.notify_receiving_message
    
      if message.parent_message_id
        parent = MsgMessage.find(message.parent_message_id)
        parent_receiver = parent.msg_receiver(current_base_user.id)
        parent_receiver.replied_flag = true
        parent_receiver.save
      end
    end
    
    if request.mobile?
      redirect_to :action => 'done', :id => message.id
    else
      redirect_to :action => :draft_list
    end
  end
  
  def delete_draft_messages_confirm
    params[:del] = params[:message_ids] unless request.mobile? # FIXME 携帯とPCの仕様統一が中途半端なため苦肉の策
    unless params[:del]
      flash[:error] = t('view.flash.error.msg_message_delete_draft_messages_confirm')
      redirect_to :action => 'draft_list'
      return
    end
    @messages = MsgMessage.find(params[:del].keys)
    setup_current_user_box_count
  end
  
  def delete_draft_messages
    if cancel?
      redirect_to :action => 'draft_list'
      return
    end
    
    MsgMessage.destroy(params[:del].keys)
    if request.mobile?
      redirect_to :action => 'delete_draft_done'
    else
      flash[:notice] = t('view.flash.notice.msg_message_delete_draft_messages')
      redirect_to :action => 'draft_list'
    end
  end
  
  def reply
    reply = MsgMessage.find(params[:id])
    setup_current_user_box_count
    
    @message = MsgMessage.new({:reply_title => reply.title, :parent_message_id => reply.id })
    @receivers = [reply.msg_sender.base_user]
    render :action => 'new'
  end
  
  def reply_with_quotation
    reply = MsgMessage.find(params[:id])
    setup_current_user_box_count
    
    @message = MsgMessage.new({:reply_title => reply.title, :reply_body => reply.body, :parent_message_id => reply.id})
    @receivers = [reply.msg_sender.base_user]
    render :action => 'new'
  end
  
  def garbage_show
    setup_current_user_box_count
    @message = MsgMessage.find(params[:id])
    
    @next_message = MsgMessage.garbage(current_base_user.id).next_message(@message.id).first
    @prev_message = MsgMessage.garbage(current_base_user.id).prev_message(@message.id).first
  end
  
  def __mobile_garbage_show
    @message = MsgMessage.find(params[:id])
    setup_current_user_box_count
  end
  
  def clean_trash_box_confirm    
  end
  
  def clean_trash_box
    if cancel?
      redirect_to :action => 'garbage_list'
      return
    end
    
    MsgMessage.clean_trash_box(current_base_user.id)
    redirect_to :action => 'clean_trash_box_done'
  end

  def delete_done
  end

  def draft_done
  end

  def delete_draft_done
  end

  def delete_completely_done
  end

  def restore_done    
  end

  def clean_trash_box_done
  end
  
  # 指定されたメッセージをゴミ箱から削除する確認画面を表示する
  def delete_from_trash_box_confirm
    unless params[:del]
      flash[:error] = t('view.flash.error.msg_message_delete_from_trash_box_confirm')
      redirect_to :action => :garbage_list
      return
    end
    
    @messages = MsgMessage.find(params[:del].keys)
    setup_current_user_box_count
  end
  
  # 指定されたメッセージをゴミ箱から削除する
  def delete_from_trash_box
    if cancel?
      @messages = MsgMessage.garbage_messages_with_paginate(current_base_user.id, AppResources[:msg][:message_list_size], params[:page])
      setup_current_user_box_count
      render :action => 'garbage_list'
      return
    end
    
    params[:del].keys.each do |message_del_id|
      message = MsgMessage.find(message_del_id)
      type = params[:del][message_del_id]
      case type.keys[0]
      when "'sender'"
        message.msg_sender.delete_completely
      when "'receiver'"
        message.msg_receivers.find_by_base_user_id(current_base_user.id).delete_completely
      end
    end
    flash[:notice] = t('view.flash.notice.msg_message_delete_from_trash_box')
    redirect_to :action => :garbage_list
  end
  
private

  # ゴミ箱から削除していい権限をもっているかの確認
  def sender_or_receiver_del_require
    return true if params[:del].nil?
    
    params[:del].keys.each do |message_del_id|
      message = MsgMessage.find(message_del_id)
      type = params[:del][message_del_id]
      case type.keys[0]
      when "'sender'"
        if message.msg_sender.base_user_id != current_base_user.id
          redirect_to_error("U-06008")
          return false
        end
      when "'receiver'"
        unless message.msg_receivers.find_by_base_user_id(current_base_user.id)
          redirect_to_error("U-06008")
          return false
        end
      end
    end
    true
  end
end
