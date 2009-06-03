
module BaseHelperModule
  
  # AppResources["base"]["notice_new_tearm"]日以内ならNew絵文字を出す
  # Date型の場合は純粋な日数のみで判断しTime型なら時間まで加味して判断する
  # datetime:: 日付（Time　or Date)
  def notice_new_if_new(datetime)
 	  if datetime.is_a?(Date)
      return '' if datetime < Date.today - AppResources["base"]["notice_new_tearm"]
    elsif datetime.is_a?(Time)
      return '' if datetime < Time.now - AppResources["base"]["notice_new_tearm"] * 24 * 60 * 60
    else
      return ''
    end
    "<span style='color:#FF0000; text-decoration:blink'></span>"
  end
  
  def link_to_menu(name, options = {}, html_options = nil, *parameters_for_method_reference)
    link_to(name, options , html_options, *parameters_for_method_reference)
  end
  
  def link_to_portal(name, options = {}, html_options = nil, *parameters_for_method_reference)
    link_to(name, options , html_options, *parameters_for_method_reference)
  end
  
  # ユーザーの名前でユーザーのプロフィールにリンクを張ります
  # ユーザーが無効な場合（存在しない，退会した，仮登録）の場合は deactive_user で指定した文字列を返します（リンクはなし）
  def link_to_user(base_user, deactive_user = I18n.t('view.noun.base_deative_user_show_name'))
    if base_user && base_user.active?
      link_to base_user.show_name, :controller => 'base_profile', :action => 'show', :id => base_user.id
    else
      deactive_user
    end
  end
  
  def link_to_user_without_emoticon(base_user, color = '#FF0000', deactive_user = I18n.t('view.noun.base_deative_user_show_name'))
    if base_user && base_user.active?
      link_to "<span style='color:#{color}'>" + base_user.show_name + "</span>",
              :controller => 'base_profile', :action => 'show', :id => base_user.id
    else
      deactive_user
    end    
  end
  
  def link_to_user_by_id(base_user_id, deactive_user = I18n.t('view.noun.base_deative_user_show_name'))
    base_user = BaseUser.find_by_id(base_user_id)
    link_to_user(base_user, deactive_user)
  end
  
  def link_to_user_without_emoticon(base_user, color = '#FF0000', deactive_user = I18n.t('view.noun.base_deative_user_show_name'))
    if base_user && base_user.active?
      link_to "<span style='color:#{color}'>" + base_user.show_name + "</span>",
        :controller => 'base_profile', :action => 'show', :id => base_user.id
    else
      deactive_user
    end    
  end
  
  # ログインユーザが管理者か判別する
  # return:: 管理者なら　true, そうでなければ false
  def current_base_user_manage?
    BaseUserRole.manager?(current_base_user).nil? ? false : true
  end
  
  # メール受信処理の設定値の文字列表現をかえす
  # return:: String メール受信処理の設定値の文字列表現
  def mail_receive_setting_message(setting)
    setting ? "受け取る" : "受け取らない"
  end
  
  def common_menu_on(key)
    "_on" if @common_menu == key
  end
  
  def sns_menu_on(key)
    "_on" if @sns_menu == key
  end
  
  def mng_menu_on(key)
    "_on" if @mng_menu == key
  end
  
  def safe_profile_view(profile, size, html_option={})
    if profile.nil? || profile.image.blank?
			image_tag_for_default 'icon/default_profile_image.gif', html_option
		else
			image_tag url_for_image_column(profile, :image, size), html_option
		end
  end

  # コミュニティ画像を表示する。あれば表示しなければデフォルトを利用する
  def safe_community_image_view(cmm_image, size, html_option={})
    if cmm_image.nil? || cmm_image.image.blank?
			image_tag_for_default 'icon/default_community_image.gif', html_option
		else
			image_tag url_for_image_column(cmm_image, :image, size), html_option
		end
  end
  
  # 最終ログイン日付からログインステータスを表示する
  # _param1_:: Time value 
  def login_status(value)
    [1, 3, 5, 30].each do |min|
      return "#{min}分以内" if Time.at(value) > Time.now - min * 60
    end
    [1, 3].each do |hour|
      return "#{hour}時間以内" if Time.at(value) > Time.now - hour * 60 * 60
    end
    [1, 3, 7].each do |day|
      return "#{day}日以内" if Time.at(value) > Time.now - day * 60 * 60 * 24
    end
    
    "1週間以上前"
  end
  
  def sub_tab_menus
    html =""
    if logged_in? && !current_base_user.base_menus.empty?
      current_base_user.base_menus.each do |menu|
        if menu.show?
          class_style = "span-4 "
          class_style += "current" if current_page?(menu.base_menu_master.url)
          
          html += "<li id='submenu_number_#{menu.base_menu_master_id} submenu_master_id_#{menu.base_menu_master_id}' class='#{class_style} draggable_menu'>"
          html += sub_tab_menu(menu.base_menu_master.name, menu.base_menu_master.icon, menu.base_menu_master.url)
          html += "</li>"
        end
      end
    else
      BaseMenuMaster.all_default_show_menus.each do |menu|
        class_style = "span-4 "
        class_style += "current" if current_page?(menu.url)
        
        html += "<li id='submenu_number_#{menu.num} submenu_master_id_#{menu.id}' class='#{class_style} draggable_menu'>"
        html += sub_tab_menu(menu.name, menu.icon, menu.url)
        html += "</li>"
      end
    end
    html
  end
  
  def sub_sub_tab_menus
    html =""
    if logged_in? && !current_base_user.base_menus.empty?
      current_base_user.base_menus.each do |menu|
        unless menu.show?
          html += "<li id='submenu_number_#{menu.num} submenu_master_id_#{menu.base_menu_master_id}' class='span-4 draggable_menu'>"
          html += sub_tab_menu(menu.base_menu_master.name, menu.base_menu_master.icon, menu.base_menu_master.url)
          html += "</li>"
        end
      end
    else
      BaseMenuMaster.all_default_unshow_menus.each do |menu|
        html += "<li id='submenu_number_#{menu.num} submenu_master_id_#{menu.id}' class='span-4 draggable_menu'>"
        html += sub_tab_menu(menu.name, menu.icon, menu.url)
        html += "</li>"
      end
    end
    html
  end
  
  def sub_tab_menu(title, image, options = {}, html_options = nil, *parameters_for_method_reference)
    link_to ""
    div_html = <<-END
      <div class="submenu_inner sub_menu_off tab_off">
    		<div class="sub_menu_title_col">
    			<div class="sub_menu_title">#{title}</div>
    		</div>
    		<img src="/images/default/icon/#{image}.gif" width="32" height="32" border="0">
    	</div>
    	</a>
    END
    link_to div_html, options, html_options, *parameters_for_method_reference
  end
  
  def has_user_notice_message?
    if (@unread_messages_count && !@unread_messages_count.zero?) ||
       (@friend_applies_count && !@friend_applies_count.zero?) ||
       (@unread_entry_comments_count && !@unread_entry_comments_count.zero?)
       true
    else
      false
    end
  end
end
