#
# ActiveFormでもValidatesDateTimeを有効にする
#
class ActiveForm
  def execute_callstack_for_multiparameter_attributes; end
  
  include ValidatesDateTime 
end

# YYYY/MM/DD というフォーマットも対応可能にする
# http://d.hatena.ne.jp/kusakari/20080409/1207675321
module ActiveRecord
  module ConnectionAdapters
    class Column
      class << self
        def string_to_date(value)
          return if value.blank?
          return value if value.is_a?(Date)
          return value.to_date if value.is_a?(Time) || value.is_a?(DateTime)
          
          year, month, day = case value.strip
            # 2006/01/01
            when /\A(\d{4})\/(\d{1,2})\/(\d{1,2})\Z/
              [$1, $2, $3]
            # 2006-01-01
            when /\A(\d{4})-(\d{1,2})-(\d{1,2})\Z/
              [$1, $2, $3]
            # Not a valid date string
            else
              return nil
          end
          
          Date.new(unambiguous_year(year), month_index(month), day.to_i) rescue nil
        end
      end
    end
  end
end
