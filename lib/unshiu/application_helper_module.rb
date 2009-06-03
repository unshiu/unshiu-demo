module Unshiu::ApplicationHelperModule
  
  # style を yml から取得する
  def style_value(key)
    StyleResources[key]
  end
  
  def charset
    if request.mobile?
      mobile = request.mobile
      # 条件式は Jpmobile::Filter::Sjis.apply_incoming? からのコピペ
      if mobile && !(mobile.instance_of?(Jpmobile::Mobile::Vodafone)||mobile.instance_of?(Jpmobile::Mobile::Softbank))
        'Shift-JIS'
      else
        'UTF-8'
      end
    else
      'UTF-8'
    end
  end
  
  def style_tag_for_mobile
    <<-END
<style type="text/css">
<![CDATA[a:link{color:#F75200}a:focus{color:#FFFFFF}]]><br />
</style>
    END
  end

  # リストを交互に背景色を変えるデフォルトのデザインに装飾する
  # _param1_:: style_options
  #
  # Examples ) 
  # <% list_cell_for do %>
	#	  <%= date_or_time(base_user.updated_at) %>
	# <% end %>
  def list_cell_for(style_options=nil, &block)
    concat("<div style=\"#{style_value('list_' + cycle('even','odd'))} #{style_options}\">", &block)
    concat("#{image_tag_for_default 'Spec_02.gif'}", &block)
    concat("<br/>", &block)
    yield
    concat("#{image_tag_for_default 'Spec_02.gif'}", &block)
    concat("<br/>", &block)
    concat("</div>", &block)
  end
  
  def link_to_list_cell(name, options = {}, html_options = nil, *parameters_for_method_reference)
    link_to(name, options , html_options, *parameters_for_method_reference)
  end
  
  def link_basic_to(name, options = {}, html_options = nil, *parameters_for_method_reference)
    link_to(name, options , html_options, *parameters_for_method_reference)
  end
  
  # コンテンツを作成する際のaddmenu.gifを利用したリンクを生成
  def link_add_menu_to(name, options = {}, html_options = {}, *parameters_for_method_reference)
    name = "<span>#{image_tag_for_default("icon/addmenu.gif")}#{name}</span>"
    html_options.merge!({ :class => "button" })
    link_to(name, options , html_options, *parameters_for_method_reference)
  end
  # 当日中に見ると時間を表示して、それ以外は日付を表示する helper
  def date_or_time(datetime)
    return '' unless datetime

    today = Date.today
    if today.year == datetime.year &&
      today.month == datetime.month &&
      today.day == datetime.day
      return datetime.strftime("%H:%M")
    else
      return datetime.strftime("%m/%d")
    end
  end

  def date_to_s(datetime)
    return '' unless datetime
    
    datetime.strftime("%m/%d")
  end

  def datetime_to_s(datetime)
    return '' unless datetime
    
    datetime.strftime("%Y/%m/%d %H:%M")
  end
  
  # 時間を表示せず日付のみ表示する
  def datetime_to_date(datetime)
    return '' unless datetime
    
    datetime.strftime("%Y/%m/%d")
  end
  
  # FIXME to_s が OS 依存なのか細かい原因は不明だが形式が違うことがあったので統一するためのヘルパ
  def datetime_for_hidden(datetime)
    return nil unless datetime
    datetime.strftime("%Y-%m-%d %H:%M:%S")    
  end
  
  # PKG標準画像を取得
  # _param1_:: ファイル名
  # _param2_:: image option
  def image_tag_for_default(filename, options = {})
    image_tag "/images/default/" + filename, options
  end
  
  # 年月のみ表示する
  # 与えられた値がnilだったら長さ0の文字列を返す
  def data_year_month(datetime)
    return '' unless datetime
    datetime.strftime("%Y/%m")    
  end
  
  # 文字列から Time に変換するヘルパ
  # view だと最終的にまた文字列にするので冗長だが表示形式の共通化のために利用
  def str_to_time(str)
    timearray = ParseDate.parsedate(str)
    Time::local(*timearray[0..-3]) # 後ろから3つめの要素まで
  end

  # 改行コードを <br> に置換するヘルパ
  def br(str)
    str.gsub(/\r\n|\r|\n/, "<br />")
  end
  
  # 改行コードを <br> に置換するヘルパ with html_escape
  def hbr(str)
    str = html_escape(str)
    br(str)
  end
  
  # 本文などのサマリ表示
  def body_summary(value, options = {})
    truncate(h(strip_tags(value)), :length => options[:length])
  end
  
  # キャンセルタグを出力するヘルパ
  def cancel_tag(value = nil, options = {})
    value = I18n.t("view.noun.cancel_button") unless value
    submit_tag(value, {:name => 'cancel'}.merge!(options))
  end
  
  # button tag を利用した　submit
  def submit_button_tag(label)
    button_tag("", label, "tick")
  end
  
  # button tag を利用した　cancel
  def cancel_button_tag(label = I18n.t("view.noun.cancel_button"))
    button_tag("cancel", label, "cross")
  end
  
  # button tag を利用した submitボタンを出力する
  # _param1_:: name 複数のbuttonによりsubmitされた際にcontroller側でどのbuttonがsubmitされたかを判別するためのもの
  # _param2_:: label text label
  # _param3_:: image icon image
  def button_tag(name, label, image)
    <<-END
    <button id="#{name}" type="submit" name="#{name}" value=""  class="button" >
    	<span><img src="/stylesheets/blueprint/plugins/buttons/icons/#{image}.png" alt="">#{label}</span>
    </button>
    END
  end
  
  def paginate(page_enumerator)
    return '' if page_enumerator.last_page == 1 # 1ページしかないのでリンクはなし
    link_params = params.dup
    link_params.delete('commit')
    link_params.delete('action')
    link_params.delete('controller')
    link_params.delete('page')
    
    <<-END
    <div class="pager_col pager_col_top append-bottom">
  		<div class="turnover">
  			<span class="preview_page">
  			  #{link_to '前のページへ', { :page => page_enumerator.previous_page }.merge(link_params) if page_enumerator.previous_page? }
  			</span>
  			<span>|</span>
  			<span class="next_page">
  			  #{link_to '次のページへ', { :page => page_enumerator.next_page }.merge(link_params) if page_enumerator.next_page? }
  			</span>
  		</div>
  		<div class="page_on_pages">
  			<span>#{page_enumerator.page} / #{page_enumerator.last_page} page</span>
  		</div>
  		<div class="pagenation">
				#{page_links(page_enumerator, link_params)}
			</div>
			<div class="clear"></div>
		</div>
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
        result << "<span class='pagenation_on'>#{i.to_s}</span>"
      else
        result << "<span>#{link_to(i, { :page => i }.merge(link_params))}</span>"
      end
    end
    if end_page != last_page
      result << '...'
    end
    result
  end
  
  # ページネートにまつわる情報をいろいろ表示するヘルパ
  def paginate_header(page_enumerator)
    <<-END
<div style="#{style_value('inner_title')}">
  #{image_tag_for_default 'Spec_02.gif'}<br />
  #{page_enumerator.page}/#{page_enumerator.last_page}ページ
    全#{page_enumerator.size}件<br />
  #{image_tag_for_default 'Spec_02.gif'}
</div>
#{image_tag_for_default 'Spec_04.gif'}<br />
    END
  end
  
  # ページネートにまつわるリンクをいろいろ表示するヘルパ
  def paginate_links(page_enumerator)
    return '' if page_enumerator.last_page == 1 # 1ページしかないのでリンクはなし
    
    link_params = params.dup
    link_params.delete('commit')
    link_params.delete('action')
    link_params.delete('controller')
    link_params.delete('page')
    link_params.delete('_mobilesns_session_id')
    
    # パラメータを SJIS に変換
    # ただし、文字コードが UTF8 な携帯（Vodafone 3G or Softbank）の場合は、変換しない
    mobile = request.mobile
    apply_encode = mobile && !(mobile.instance_of?(Jpmobile::Mobile::Vodafone)||mobile.instance_of?(Jpmobile::Mobile::Softbank))
    if apply_encode
      encoded_params = {}
      link_params.each{|key, value|
        encoded_params[key] = NKF.nkf('-m0 -x -Ws', value) if value && value.is_a?(String)
      }
    else
      encoded_params = link_params
    end
    
    <<-END
      <table width="100%">
        <tr>
          <td align="left"><span style="font-size:small;">
            #{link_to_portal '前のページ', { :page => page_enumerator.previous_page }.merge(encoded_params), {:accesskey => 4} if page_enumerator.previous_page?}
          </span></td>
          <td align="right"><span style="font-size:small;">
            #{link_to_portal '次のページ', { :page => page_enumerator.next_page }.merge(encoded_params), {:accesskey => 6} if page_enumerator.next_page?}
          </span></td>
        </tr>
        <tr>
          <td align="left"><span style="font-size:small;">
            #{link_to_portal '最初のページ', { :page => page_enumerator.first_page }.merge(encoded_params) unless page_enumerator.page == page_enumerator.first_page}
          </span></td>
          <td align="right"><span style="font-size:small;">
            #{link_to_portal '最後のページ', { :page => page_enumerator.last_page }.merge(encoded_params) unless page_enumerator.page == page_enumerator.last_page}
          </span></td>
        </tr>
      </table>
    END
  end
  
  # 英字入力モードに設定する
  # _additional_options_:: 追加の options。デフォルトよりこっちのほうが優先度は高い
  def alphabet_text_field_options(additional_options = {})
    options = {:istyle => 3, :mode => 'alphabet', :style => "-wap-input-format:&quot;*&lt;ja:en&gt;&quot;", :format=>'*a'}
    options.merge!(additional_options)

    if request.mobile.is_a?(Jpmobile::Mobile::Au)
      options.delete(:mode)
      options.delete(:style) # FIXME style があると au は入力モード指定に対応できなくなるようなので消している。。。がちょっと荒い
    end
    options
  end
  
  # 数字入力モードに設定する
  # _additional_options_:: 追加の options。デフォルトよりこっちのほうが優先度は高い
  def numeric_text_field_options(additional_options = {})
    options = {:istyle => 4, :mode => 'numeric', :style => "-wap-input-format:&quot;*&lt;ja:n&gt;&quot;", :format=>'*N'}
    # NOTICE format = "*N" は au を数字しか入力できないよう制限するらしい
    #        format = "*m" にすると英小文字スタートになるが、全入力モードが使える
    options.merge!(additional_options)
    
    if request.mobile.is_a?(Jpmobile::Mobile::Au)
      options.delete(:mode)
      options.delete(:style) # FIXME style があると au は入力モード指定に対応できなくなるようなので消している。。。がちょっと荒い
    end
    options
  end

  def error_messages_for(*params)
    if request.mobile?
      # 携帯なら自前のヘルパへ
      error_messages_for_mobile(*params)
    else
      # それ以外ならデフォルトのヘルパへ
      super(*params)
    end
  end
  
  # 携帯用エラーメッセージヘルパ
  def error_messages_for_mobile(*params)
    options = params.extract_options!.symbolize_keys
    
    if object = options.delete(:object)
      objects = [object].flatten
    else
      objects = params.collect {|object_name| instance_variable_get("@#{object_name}") }.compact
    end
    
    count  = objects.inject(0) {|sum, object| sum + object.errors.count }
    unless count.zero?
      html = {}
      html[:style] = style_value('error_div')    
      [:id, :class].each do |key|
        if options.include?(key)
          value = options[key]
          html[key] = value unless value.blank?
        else
          html[key] = 'errorExplanation'
        end
      end
      options[:object_name] ||= params.first
      
      I18n.with_options :locale => options[:locale], :scope => [:activerecord, :errors, :template] do |locale|
        header_message = if options.include?(:header_message)
          options[:header_message]
        else
          object_name = options[:object_name].to_s.gsub('_', ' ')
          object_name = I18n.t(object_name, :default => object_name, :scope => [:activerecord, :models], :count => 1)
          locale.t :header, :count => count, :model => object_name
        end
        
        message = options.include?(:message) ? options[:message] : locale.t(:body)
        error_messages = objects.sum {|object| object.errors.full_messages.map {|msg| content_tag(:li, msg) } }.join
        
        content_tag(:div,
            content_tag(options[:header_tag] || :span, '&#xE6FE;' + header_message, {:style => style_value('error_div_message')}) <<
            '<br/>' <<
            error_messages.to_s,
          html)
      end
    else
      ''
    end
  end
  
  def error_message_on_for_mobile(object, method, prepend_text = "", append_text = "")
    if (obj = instance_variable_get("@#{object}")) && (errors = obj.errors.on(method))
      content = []
      content << "<span style=\"color:#ff0000;\">"
      content <<  "#{prepend_text}#{errors.is_a?(Array) ? errors.first : errors}#{append_text}"
      content << "</span>"
      content.join
    else 
       ''
    end
  end 
  
  # 日付を調整するobserve_fieldを追加する
  # またその後で表示されたタイミングの日付を調整の初期化をするJSを追加する
  # _param1_:: モデル名
  # _param2_:: フィールド名
  def adjusted_datetime(model_name, field_name)
    id_1i = "##{model_name}_#{field_name}_1i"
    id_2i = "##{model_name}_#{field_name}_2i"
    id_3i = "##{model_name}_#{field_name}_3i"
    <<-END
      #{observe_field id_1i, :url => {:controller => :application, :action => 'adjusted_datetime', :model_name => model_name, :field_name => field_name}, 
                             :with => "'year=' + escape(value) + '&month=' + escape($('#{id_2i} option:selected').attr('value')) + '&day=' + escape($('#{id_3i} option:selected').attr('value'))"}
      #{observe_field id_2i, :url => {:controller => :application, :action => 'adjusted_datetime', :model_name => model_name, :field_name => field_name},
                             :with => "'year=' + escape($('#{id_1i} option:selected').attr('value')) + '&month=' + escape(value) + '&day=' + escape($('#{id_3i} option:selected').attr('value'))"}
	    
	    <script type="text/javascript">
	      $(function() {
	        #{remote_function(:url => {:controller => :application, :action => 'adjusted_datetime', :model_name => model_name, :field_name => field_name},
  	                        :with => "'year=' + escape($('#{id_1i} option:selected').attr('value')) + '&month=' + escape($('#{id_2i} option:selected').attr('value')) + '&day=' + escape($('#{id_3i} option:selected').attr('value'))")}
  	    });
      </script>
	  END
	end
	
	# 画像がない場合にエラーにならないようにする
  # _param1_:: source
  # _param2_:: options
	def safety_image_tag(source, options = {})
    image_tag(source, options) unless source.nil?
  end
  
  # hashをソート済み配列に変換する
  # _param1_:: hash
  # return :: ソートされて順番を保持した配列
  def hash2sorted_array(hash)
    hash.to_a.sort { |a,b| a[0] <=> b[0] }
  end
  
  # hashをselect tag用の一覧にして返す
  # _param1_:: hash
  # return :: select tag 用一覧
  def select_type(hash)
    hash.to_a.sort.collect{ |key, val| [val, key] }
  end
  
  # 対象ファイルがあれば描画し、ない場合は例外を出さず無視する
  # _param1_:: value
  def sefe_render(value)
    render value
  rescue
  end
  
  # エラーメッセージにエラー発生元情報も表示するように
  # error_message_onを参照のこと
  def error_message_on_with_label(object, method, *args)
    options = args.extract_options!
    options.reverse_merge!(:prepend_text => '', :append_text => '', :css_class => 'formError')

    if (obj = (object.respond_to?(:errors) ? object : instance_variable_get("@#{object}"))) &&
      (errors = obj.errors.on(method))
      content_tag("div",
                  "#{options[:prepend_text]}" +
                  I18n.t("activerecord.attributes." + object.class.to_s.underscore + "." + method.to_s,
                  :default => method.to_s) +
                  "#{errors.is_a?(Array) ? errors.first : errors}#{options[:append_text]}",
                  :class => options[:css_class]
      )
    else
      ''
    end
  end
end