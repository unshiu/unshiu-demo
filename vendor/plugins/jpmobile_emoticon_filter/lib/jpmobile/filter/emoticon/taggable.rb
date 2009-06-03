# jpMobileのUTF-8内部表現をimgタグに変換するフィルタ

# 変換テーブル
require 'jpmobile/emoticon/docomo_unicode_to_typepad'

class ActionController::Base #:nodoc:
  def self.emoticon_filter(options = {})
    around_filter Jpmobile::Filter::Emoticon::Taggable.new(options) # 数値文字参照<->IMGタグ
  end
end

module Jpmobile
  module Filter
    module Emoticon
      class Taggable < Jpmobile::Filter::Base
        INSIDE_INPUT_TAG = Regexp.new('(<input\s.*?\svalue=")(.*?)(".*?>)').freeze
        INSIDE_TEXTAREA_TAG = Regexp.new('(<textarea\s.*?>)(.*?)(</textarea>)', Regexp::MULTILINE).freeze

        def initialize(options)
          super()
          @classname = options[:classname] || 'emoticon'
          @emoticon_dir = options[:path] || 'emoticons'
          @only = [].push(options[:only]).flatten.compact
          @except  = [].push(options[:except]).flatten.compact
        end

        def apply_outgoing?(controller)
          [nil,
           "text/html",
           "application/xhtml+xml"].include?(controller.response.content_type) || javascript?(controller)
        end

        def javascript?(controller)
          ["text/javascript",
           "application/javascript"].include?(controller.response.content_type)
        end

        # Unicode数値文字参照及びUTF8を絵文字タグに変換
        def to_external(str, controller)
          return str if controller.request.mobile?
          
          # 数値文字参照をUTF8で置き換え（&#xE63E;などで記載されていればそれをUTF8に変換）
          utf8_str = Jpmobile::Emoticon::unicodecr_to_utf8(str)
 
          return str unless Jpmobile::Emoticon::UTF8_REGEXP =~ utf8_str
 
          # input内の絵文字をPC編集用タグに置換する。
          utf8_str.gsub!(INSIDE_INPUT_TAG) do
            prefix, value, suffix = $1, $2, $3
            prefix << value.gsub(Jpmobile::Emoticon::UTF8_REGEXP){ |m| "[emo:#{ m.unpack('U').first}]"} << suffix
          end
 
          # textarea内の絵文字をPC編集用タグに置換する。
          utf8_str.gsub!(INSIDE_TEXTAREA_TAG) do
            prefix, value, suffix = $1, $2, $3
            prefix << value.gsub(Jpmobile::Emoticon::UTF8_REGEXP){|m| "[emo:#{m.unpack('U').first}]"} << suffix
          end

          # 数値文字参照をUTF8で置き換え、（&#xE63E;などで記載されていればそれをUTF8に変換）
          # さらに絵文字に該当するコードをそれぞれDoCoMo公式のマッピングで置き換えた上で
          # IMGタグで置換する。
          img_builder = unless javascript?(controller)
                          Proc.new { |emoticon_path| "<img src=\"#{emoticon_path}\" class=\"#{@classname}\" />" }
                        else
                          Proc.new { |emoticon_path| "<img src=\\\"#{emoticon_path}\\\" class=\\\"#{@classname}\\\" />" }
                        end
          utf8_str.gsub(Jpmobile::Emoticon::UTF8_REGEXP) do |match|
            docomo_code = Jpmobile::Emoticon::CONVERSION_TABLE_TO_DOCOMO[match.unpack('U').first]
            if Jpmobile::Emoticon::DOCOMO_UNICODE_TO_TYPEPAD[docomo_code]
              img_builder.call(File.join(controller.request.relative_url_root,
                                       "images",
                                       @emoticon_dir,
                                       Jpmobile::Emoticon::DOCOMO_UNICODE_TO_TYPEPAD[docomo_code] || "[&#x#{docomo_code}]"))
            else
              "[#{docomo_code}]"  # 変換テーブルにないもの
            end
          end
        end

        # 絵文字タグをDoCoMo公式マッピングで変換
        def to_internal(str, controller)
          return str if controller.request.mobile?
          str.gsub(/(\[emo:)([0-9]+)(\])/){ 
            [Integer($2)].pack('U')
          }.gsub(/<img src="([^"]+)"[^>]*>/) do |match|
            docomo_code = Jpmobile::Emoticon::TYPEPAD_TO_DOCOMO_UNICODE[File.basename($1)]
            docomo_code ? [docomo_code].pack('U') : match
          end
        end

        def deep_each(obj, &proc)
          if obj.is_a? Hash
            obj.each_pair do |key, value|
              obj[key] = deep_each(value, &proc)
            end
          elsif obj.is_a? Array
            obj.collect!{|value| deep_each(value, &proc)}
          elsif not (obj==nil || obj.is_a?(TrueClass) || obj.is_a?(FalseClass))
            unless obj.is_a?(Tempfile) || obj.is_a?(StringIO)
              obj = obj.to_param if obj.respond_to?(:to_param)
              proc.call(obj)
            else
              obj
            end
          end
        end

      end
    end
  end
end
