module ManageApplicationHelperModule
  # html_escape & 絵文字を [絵文字] という文字列に変換する
  def h(str)
    str = html_escape(str)
    str.gsub(Jpmobile::Emoticon::UTF8_REGEXP, '[絵文字]')
  end
  
  # html_escape & 改行コードを <br/> に変換 & 絵文字を [絵文字] という文字列に変換する
  def br(str)
    tmp = str.gsub(/\r\n|\r|\n/, "<br/>")
    tmp.gsub(Jpmobile::Emoticon::UTF8_REGEXP, '[絵文字]')
  end

  # manage側の br に呼び先が変わるから一応定義しておく
  def hbr(str)
    str = html_escape(str)
    br(str)
  end

  def date_to_s(datetime)
    return '' unless datetime
    
    datetime.strftime("%y/%m/%d")
  end
  
  # ユーザーの名前でユーザーのプロフィールにリンクを張ります
  # ユーザーが無効な場合（存在しない，退会した，仮登録）の場合は deactive_user で指定した文字列を返します（リンクはなし）
  def link_to_user(base_user, deactive_user = I18n.t('view.noun.base_deative_user_show_name'))
    if base_user && base_user.active?
      link_to base_user.show_name, :controller => 'manage/base_user', :action => 'show', :id => base_user.id
    else
      deactive_user
    end
  end
  
  # ページネートにまつわる情報をいろいろ表示するヘルパ
  def paginate_header(page_enumerator)
    <<-END
      <div align="center">#{page_enumerator.page}/#{page_enumerator.last_page}ページ</div>
      <div align="right">全#{page_enumerator.size}件</div>
    END
  end
  
  # ページネートにまつわるリンクをいろいろ表示するヘルパ
  def paginate_links(page_enumerator)
    link_params = params.dup
    link_params.delete('commit')
    link_params.delete('action')
    link_params.delete('controller')
    link_params.delete('page')
    link_params.delete('_mobilesns_session_id')
    
    <<-END
      <table width="100%">
        <tr>
          <td align="left" width="20%">
            #{link_to '前のページへ', { :page => page_enumerator.previous_page }.merge(link_params) if page_enumerator.previous_page?}
          </td>
          <td align="center">
            #{page_links(page_enumerator, link_params)}
          </td>
          <td align="right" width="20%">
            #{link_to '次のページへ', { :page => page_enumerator.next_page }.merge(link_params) if page_enumerator.next_page?}
          </td>
        </tr>
      </table>
    END
  end
  
  def page_links(page_enumerator, link_params)
    result = ''
    current = page_enumerator.page
    last_page = page_enumerator.last_page
    start_page = current - 5
    start_page = 1 if start_page < 1
    end_page = start_page + 10
    end_page = last_page if end_page > last_page
    
    if start_page != 1
      result << '...'
    end
    for i in start_page..end_page
      if i == page_enumerator.page
        result << "<span class='page_link'>#{i.to_s}</span>"
      else
        result << "<span class='page_link'>#{link_to(i, { :page => i }.merge(link_params))}</span>"
      end
    end
    if end_page != last_page
      result << '...'
    end
    result
  end
  
  # 管理画面用のsubmitタグを出力するヘルパ
  def mng_submit_tag(value, options = {})
    submit_tag(value, {:class => 'button'}.merge!(options))
  end
  
  # 管理画面用のキャンセルタグを出力するヘルパ
  def mng_cancel_tag(value = nil, options = {})
    value = I18n.t('view.noun.cancel_button') unless value
    submit_tag(value, {:name => 'cancel', :class => 'cancel_button'}.merge!(options))
  end
  
end
