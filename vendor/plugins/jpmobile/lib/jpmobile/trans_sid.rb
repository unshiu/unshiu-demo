# = セッションIDの付与
#
# based on http://moriq.tdiary.net/20070209.html#p01
# by moriq <moriq@moriq.com>
#
# cookie support detection inspired by takai http://recompile.net/
#
# Rails 2.0.2 support is based on the code contributed
# by masuidrive <masuidrive (at) masuidrive.jp>

# FastCGI環境では(どういうわけか) cgi.query_string でクエリ文字列を取得できないので
# ENV['QUERY_STRING'] に代入しておく。
# セッションIDを Cookie 以外からも見るようにする変更
ActionController::Base.session = {:cookie_only => false}

module ActionController
  class CgiRequest
    alias_method :initialize_without_ext, :initialize
    def initialize(cgi, options = {})
      initialize_without_ext(cgi, options)
      ENV['QUERY_STRING'] = query_string
    end
  end
end

class ActionController::Base #:nodoc:
  class_inheritable_accessor :trans_sid_mode
  alias :transit_sid_mode :trans_sid_mode
  class << self
    def trans_sid(mode=:mobile)
      include Jpmobile::TransSid
      self.trans_sid_mode = mode
    end
    
    alias :transit_sid :trans_sid
  end
end

module Jpmobile::TransSid #:nodoc:
  def self.included(controller)
    controller.after_filter(:append_session_id_parameter)
  end

  protected
  # URLにsession_idを追加する。
  def default_url_options(options=nil)
    return unless request # for test process
    return unless apply_trans_sid?
    { session_key => request.session_options[:id] }
  end

  private
  # session_keyを返す。
  def session_key
    key = '_sesssion_id'
    unless request.env["rack.session.options"].nil? 
      key = request.env["rack.session.options"][:key]
    end
    key
  end
  
  # session_idを埋め込むためのhidden fieldを出力する。
  def sid_hidden_field_tag
    "<input type=\"hidden\" name=\"#{CGI::escapeHTML session_key}\" value=\"#{CGI::escapeHTML request.session_options[:id]}\" />"
  end
  # formにsession_idを追加する。
  def append_session_id_parameter
    return unless request # for test process
    return unless apply_trans_sid?
    response.body.gsub!(%r{(</form>)}i, sid_hidden_field_tag+'\1')
  end
  # trans_sidを適用すべきかを返す。
  def apply_trans_sid?
    return false unless session.is_a? ActionController::Session::AbstractStore::SessionHash
    return false if trans_sid_mode == :none
    return true if trans_sid_mode == :always
    if trans_sid_mode == :mobile
      if request.mobile?
        return !request.mobile.supports_cookie?
      else
        return false
      end
    end
    return false
  end
end
