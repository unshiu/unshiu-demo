#= Unshiu::ApplicationControllerModule
#
#== Summary
# unshiu アプリケーションとしての規程 module
# 
module Unshiu::ApplicationControllerModule
  
  class << self
    def included(base)
      base.extend(ClassMethods)
      base.class_eval do
        include ExceptionNotifiable
        include AuthenticatedSystem
        
        layout :base_layout
        
        protect_from_forgery
        
        # 生パスワードをログに出力させない 
        filter_parameter_logging :password
        
        # 携帯向けのセッション保持
        transit_sid
         
        # SJIS化
        # 半角カナ変換あり
        mobile_filter :hankaku => true
        emoticon_filter :editable_tag => false
        
        # docomoはインラインCSSを使うのにもContent-Typeの指定までしないといけない。不便。
        # TODO jpmobile にいれてしまいたい
        after_filter :set_header
        
        before_filter :set_locale
        
        before_filter :login_from_cookie
      end
    end
  end

  # selectボックスで日付を選択する際に月の最終日を調整する
  def adjusted_datetime
    @model_name = params[:model_name]
    @field_name = params[:field_name]
    @year =  params[:year]
    @month = params[:month]
    @day =   params[:day]
    @day_count = Time.days_in_month(@month.to_i,@year.to_i)
    render :template => '/common/adjusted_datetime', :layout => false
  end

private

  def set_header
    if request.mobile?
      if request.mobile.is_a?(Jpmobile::Mobile::Docomo)
        headers['Content-Type'] = 'application/xhtml+xml;charset=Shift_JIS'
      end
    end
  end
  
  # 環境がdevelopmentの場合だけtrueをかえす。
  # _return_ developmentのときはtrue, それ以外はfalse
  def development?
    RAILS_ENV == 'development' ? true : false
  end
  
  # キャンセルボタン（:name => 'cancel' なボタン）が押されていれば true
  def cancel?
    params[:cancel] != nil
  end
  
  # キャンセル後に遷移するURLへリダイレクト処理をする
  def cancel_to_return
    if request.mobile? && !request.mobile.supports_cookie? && request.session_options
      plug = params[:cancel_to].index("?") == nil ? "?" : "&"
      params[:cancel_to] += "#{plug}#{request.session_options[:key]}=#{request.session_options[:id]}"
    end
   
    redirect_to params[:cancel_to]
  end
  
  # ログイン状態ではキャッシュを生成しない
  def cache_erb_fragment(block, name = {}, options = nil)
    if logged_in? then block.call; return end
    
    if @expire_fragment && @expire_fragment.key?(name)
      buffer = eval("_erbout", block.binding)
      pos = buffer.length
      block.call
      write_fragment(name, buffer[pos..-1], options)
      return
    end

    super
  end

  # 有効時間内の fragment cache があれば true
  # 有効時間を過ぎたキャッシュがある場合は消して、false
  # キャッシュがない場合 false
  def has_active_fragment_cache?(name, time = -10.minute, options = nil)
    return false unless perform_caching
    return false if logged_in?
    
    Rails.cache.exist?(name)
    
    fragment_cache_key = fragment_cache_key(name)
    cache_check_file = "#{ActionController::Base.page_cache_directory}#{fragment_cache_key}.cache"
    
    if File.exist?(cache_check_file)
      unless File.mtime(cache_check_file) > time.from_now
        @expire_fragment = {} if @expire_fragment.nil?
        @expire_fragment[name] = options
        return false
      end
      return true
    end
    return false
  end
  
  # 指定時刻以降に生成した fragment cache があれば true
  # 指定時刻より前のキャッシュがある場合は消して、false
  # キャッシュがない場合 false
  # _refresh_time_:: キャッシュを更新したい時刻(Time)
  def has_fresh_fragment_cache?(name, refresh_time, options = nil)
    return false unless perform_caching
    return false if logged_in?
    
    fragment_cache_key = fragment_cache_key(name)
    cache_check_file = "#{cache.cahce_path}#{fragment_cache_key}.cache"
    
    if File.exist?(cache_check_file)
      if File.mtime(cache_check_file) < refresh_time
        @expire_fragment = {} if @expire_fragment.nil?
        @expire_fragment[name] = options
        return false
      end
      return true
    end
    return false
  end
  
  def base_layout
    suffix = request.mobile? ? '_mobile' : ''
    return "_done#{suffix}" if action_name =~ /done$/
    return "_application#{suffix}"
  end

  def set_locale
    I18n.locale = "ja-JP"
  end

  module ClassMethods
    
    # 多段レイアウトを行うための filter 呼び出し
    # 完了メソッド（名称末尾が done なメソッド）の場合は完了用のレイアウトを使う
    # Ajaxの呼び出しである remote で終わるメソッドはレイアウトが空であるempty layoutを使う
    # 完了メソッドの自動割り出しを行っているため、
    # 各 Controller の“末尾”でこのメソッドを呼び出してください
    def nested_layout_with_done_layout(main_layout = nil)
      
      methods = self.public_instance_methods
      done_methods = methods.reject { |m| !(/done$/ =~ m) }
      remote_methods = methods.reject { |m| !(/remote$/ =~ m) }
      
      if main_layout.nil?
        nested_layout nil, :except => done_methods + remote_methods
      else
        nested_layout [main_layout], :except => done_methods + remote_methods
      end
      nested_layout ["empty"], :only => remote_methods
      nested_layout ['done'], :only => done_methods
    end
  end
end