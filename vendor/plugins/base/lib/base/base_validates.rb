require 'active_form'

#= BaseValidatesModule
#
#== Summary
# baseプラグイン内で利用される汎用的な validater
module BaseValidatesModule
  
  # NGワード用 validater
  def validates_good_word_of(*attr_names)
    configuration = {:message => "に不適切な言葉が含まれています。"}
    configuration.update(attr_names.pop) if attr_names.last.is_a?(Hash)
    
    validates_each(attr_names,configuration) do |record, attr_name, value|
      next unless value
      regexp_ng = BaseNgWord.regexp    
      
      if regexp_ng =~ value
        record.errors.add(attr_name, configuration[:message])
      end
    end
  end
  
  # メールアドレスの形式用 validator
  # 携帯キャリアがRFC違反のメールアドレスを許可しているため、厳密なチェックは行わない
  def validates_legal_mail_address_of(*attr_names)
    configuration = {:with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i}
    configuration.update(attr_names.pop) if attr_names.last.is_a?(Hash)
    attr_names << configuration
    
    validates_format_of *attr_names
  end

  # 絵文字を含んでいないか validator
  def validates_not_include_emoticon_of(*attr_names)
    configuration = {:message => "に絵文字を含むことはできません。"}
    configuration.update(attr_names.pop) if attr_names.last.is_a?(Hash)
    
    validates_each(attr_names,configuration) do |record, attr_name, value|
      next unless value
      next unless value.is_a?(String)
      unless value.scan(Jpmobile::Emoticon::UTF8_REGEXP).empty?
        record.errors.add(attr_name, configuration[:message])
      end
    end
  end
end

module ActiveRecord  
  class Base
    class << self
      include BaseValidatesModule
    end
  end
end

class ActiveForm
  
  class << self
    include BaseValidatesModule
  end
  
end
